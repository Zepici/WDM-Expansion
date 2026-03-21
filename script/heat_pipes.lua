local heat_pipes = {}

local PIPE_PREFIX_PATTERN = "linked%-heat%-pipe%-"

-- runtime cache (not persisted)
local heat_pipe_cache = {} -- [unit_number] = entity

local function init_storage()
    storage.linked_heat_pipes = storage.linked_heat_pipes or {} -- [unit_number] = {name, surface_index, position}
    storage.heat_pipe_sync_enabled = storage.heat_pipe_sync_enabled or false
end

local function is_linked_heat_pipe(name)
    return name and name:find(PIPE_PREFIX_PATTERN) ~= nil
end

local function find_entity_for_record(record)
    if not record then return nil end
    local surface = record.surface_index and game.surfaces[record.surface_index]
    if not (surface and surface.valid and record.name and record.position) then return nil end
    local found = surface.find_entities_filtered{
        name = record.name,
        position = record.position,
        radius = 0.5,
        limit = 1
    }
    return found and found[1] or nil
end

local function has_any_pipes()
    return storage.linked_heat_pipes and next(storage.linked_heat_pipes) ~= nil
end

local function sync_linked_heat_pipes()
    if not storage.linked_heat_pipes then return end

    local grouped = {} -- grouped[name] = {entities}

    for unit_number, rec in pairs(storage.linked_heat_pipes) do
        local ent = heat_pipe_cache[unit_number]
        if not (ent and ent.valid) then
            ent = find_entity_for_record(rec)
            heat_pipe_cache[unit_number] = ent
        end

        if ent and ent.valid then
            local list = grouped[rec.name]
            if not list then list = {}; grouped[rec.name] = list end
            list[#list + 1] = ent
        else
            storage.linked_heat_pipes[unit_number] = nil
            heat_pipe_cache[unit_number] = nil
        end
    end

    for _, pipes in pairs(grouped) do
        if #pipes > 1 then
            local max_temp = 0
            for _, p in ipairs(pipes) do
                local t = p.temperature
                if t and t > max_temp then max_temp = t end
            end
            if max_temp > 0 then
                for _, p in ipairs(pipes) do
                    if p.valid and p.temperature ~= max_temp then
                        pcall(function() p.temperature = max_temp end)
                    end
                end
            end
        end
    end
end

local function refresh_heat_pipe_tick()
    if storage.heat_pipe_sync_enabled and has_any_pipes() then
        script.on_nth_tick(10, sync_linked_heat_pipes)
    else
        script.on_nth_tick(10, nil)
    end
end

local function on_pipe_built(event)
    local entity = event.entity or event.created_entity
    if not (entity and entity.valid) then return end
    if not is_linked_heat_pipe(entity.name) then return end

    storage.linked_heat_pipes[entity.unit_number] = {
        name = entity.name,
        surface_index = entity.surface.index,
        position = entity.position
    }
    heat_pipe_cache[entity.unit_number] = entity
    storage.heat_pipe_sync_enabled = true
    refresh_heat_pipe_tick()
end

local function on_pipe_removed(event)
    local entity = event.entity
    if not entity then return end
    if not is_linked_heat_pipe(entity.name) then return end

    storage.linked_heat_pipes[entity.unit_number] = nil
    heat_pipe_cache[entity.unit_number] = nil

    if not has_any_pipes() then
        storage.heat_pipe_sync_enabled = false
    end
    refresh_heat_pipe_tick()
end

function heat_pipes.on_init_or_configuration_changed()
    init_storage()
    refresh_heat_pipe_tick()
end

function heat_pipes.on_load()
    refresh_heat_pipe_tick()
end

function heat_pipes.on_entity_built(event)
    on_pipe_built(event)
end

function heat_pipes.on_entity_removed(event)
    on_pipe_removed(event)
end

return heat_pipes
