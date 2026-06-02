local heat_pipes = {}

local PIPE_PREFIX_PATTERN = "linked%-heat%-pipe%-"

-- runtime cache (not persisted)
local heat_pipe_cache = {} -- [unit_number] = entity
local reuse_grouped = {}
local refresh_heat_pipe_tick

local function init_storage()
    storage.linked_heat_pipes = storage.linked_heat_pipes or {} -- [unit_number] = {name, surface_index, position}
    storage.heat_pipe_sync_enabled = storage.heat_pipe_sync_enabled or false
    storage.linked_heat_pipe_destroy_registrations = storage.linked_heat_pipe_destroy_registrations or {
        by_registration = {}, -- [registration_number] = unit_number
        by_unit_number = {} -- [unit_number] = registration_number
    }
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

local function clear_pipe_destroy_registration(unit_number)
    local registrations = storage.linked_heat_pipe_destroy_registrations
    if not (registrations and unit_number) then return end

    local registration_number = registrations.by_unit_number[unit_number]
    if registration_number then
        registrations.by_unit_number[unit_number] = nil
        registrations.by_registration[registration_number] = nil
    end
end

local function register_pipe_for_destroy_event(entity)
    if not (entity and entity.valid and entity.unit_number) then return end

    local registrations = storage.linked_heat_pipe_destroy_registrations
    local unit_number = entity.unit_number
    local registration_number = registrations.by_unit_number[unit_number]
    if registration_number then
        registrations.by_registration[registration_number] = unit_number
        return
    end

    local registered = script.register_on_object_destroyed(entity)
    if registered then
        registrations.by_unit_number[unit_number] = registered
        registrations.by_registration[registered] = unit_number
    end
end

local function apply_event_filters()
    local filters = {{filter = "type", type = "heat-pipe"}}
    script.set_event_filter(defines.events.on_built_entity, filters)
    script.set_event_filter(defines.events.on_robot_built_entity, filters)
    script.set_event_filter(defines.events.on_space_platform_built_entity, filters)
    script.set_event_filter(defines.events.script_raised_built, filters)
    script.set_event_filter(defines.events.script_raised_revive, filters)
end

local function remove_pipe_by_unit_number(unit_number)
    if not unit_number then return end
    storage.linked_heat_pipes[unit_number] = nil
    heat_pipe_cache[unit_number] = nil
    clear_pipe_destroy_registration(unit_number)

    if not has_any_pipes() then
        storage.heat_pipe_sync_enabled = false
    end
    refresh_heat_pipe_tick()
end

local function rebuild_destroy_registrations()
    local registrations = storage.linked_heat_pipe_destroy_registrations
    registrations.by_registration = {}
    registrations.by_unit_number = {}
    local has_pipes = false

    for unit_number, record in pairs(storage.linked_heat_pipes) do
        local entity = heat_pipe_cache[unit_number]
        if not (entity and entity.valid) then
            entity = find_entity_for_record(record)
            heat_pipe_cache[unit_number] = entity
        end

        if entity and entity.valid then
            has_pipes = true
            register_pipe_for_destroy_event(entity)
        else
            clear_pipe_destroy_registration(unit_number)
            storage.linked_heat_pipes[unit_number] = nil
            heat_pipe_cache[unit_number] = nil
        end
    end

    storage.heat_pipe_sync_enabled = has_pipes
end

local function sync_linked_heat_pipes()
    if not storage.linked_heat_pipes then return end

    for _, list in pairs(reuse_grouped) do
        local list_size = #list
        if list_size > 0 then
            for i = 1, list_size do list[i] = nil end
        end
    end

    for unit_number, rec in pairs(storage.linked_heat_pipes) do
        local ent = heat_pipe_cache[unit_number]
        if not (ent and ent.valid) then
            ent = find_entity_for_record(rec)
            heat_pipe_cache[unit_number] = ent
        end

        if ent and ent.valid then
            local list = reuse_grouped[rec.name]
            if not list then list = {}; reuse_grouped[rec.name] = list end
            list[#list + 1] = ent
        else
            clear_pipe_destroy_registration(unit_number)
            storage.linked_heat_pipes[unit_number] = nil
            heat_pipe_cache[unit_number] = nil
        end
    end

    for _, pipes in pairs(reuse_grouped) do
        local count = #pipes
        if count > 1 then
            local total_temp = 0
            local valid_count = 0
            
            for i = 1, count do
                local p = pipes[i]
                local t = p.temperature
                if t then
                    total_temp = total_temp + t
                    valid_count = valid_count + 1
                end
            end

            if valid_count > 0 then
                local average_temp = total_temp / valid_count
                for i = 1, count do
                    local p = pipes[i]
                    if p.valid then
                        p.temperature = average_temp
                    end
                end
            end
        end
    end
end

local function on_entity_cloned(event)
    local source = event.source
    if not (source and source.valid and is_linked_heat_pipe(source.name)) then return end
    
    local destination = event.destination
    if not (destination and destination.valid) then return end

    local old_id = source.unit_number
    local new_id = destination.unit_number
    local record = storage.linked_heat_pipes[old_id]

    if record then
        local dest_pos = destination.position
        storage.linked_heat_pipes[new_id] = {
            name = record.name,
            surface_index = destination.surface.index,
            position = {x = dest_pos.x, y = dest_pos.y}
        }
        heat_pipe_cache[new_id] = destination
        register_pipe_for_destroy_event(destination)
    end
end

refresh_heat_pipe_tick = function()
    if storage.heat_pipe_sync_enabled and has_any_pipes() then
        script.on_nth_tick(10, sync_linked_heat_pipes)
    else
        script.on_nth_tick(10, nil)
    end
end

local function on_pipe_built(event)
    init_storage()
    local entity = event.entity or event.created_entity
    if not (entity and entity.valid) then return end
    if not is_linked_heat_pipe(entity.name) then return end

    storage.linked_heat_pipes[entity.unit_number] = {
        name = entity.name,
        surface_index = entity.surface.index,
        position = {x = entity.position.x, y = entity.position.y}
    }
    heat_pipe_cache[entity.unit_number] = entity
    register_pipe_for_destroy_event(entity)
    storage.heat_pipe_sync_enabled = true
    refresh_heat_pipe_tick()
end

local function on_pipe_removed(event)
    local entity = event.entity
    if not entity then return end
    if not is_linked_heat_pipe(entity.name) then return end

    remove_pipe_by_unit_number(entity.unit_number)
end

function heat_pipes.on_init_or_configuration_changed()
    init_storage()
    rebuild_destroy_registrations()
    apply_event_filters()
    refresh_heat_pipe_tick()
end

function heat_pipes.on_load()
    apply_event_filters()
    if storage and storage.linked_heat_pipes and next(storage.linked_heat_pipes) ~= nil then
        script.on_nth_tick(10, sync_linked_heat_pipes)
        return
    end
    refresh_heat_pipe_tick()
end

function heat_pipes.on_entity_built(event)
    on_pipe_built(event)
end

function heat_pipes.on_entity_removed(event)
    init_storage()
    on_pipe_removed(event)
end

function heat_pipes.on_object_destroyed(event)
    init_storage()
    local registrations = storage.linked_heat_pipe_destroy_registrations
    if not registrations then return end

    local unit_number = registrations.by_registration[event.registration_number] or event.useful_id
    if not unit_number or not storage.linked_heat_pipes[unit_number] then return end
    remove_pipe_by_unit_number(unit_number)
end

function heat_pipes.on_entity_cloned(event)
    on_entity_cloned(event)
end

return heat_pipes
