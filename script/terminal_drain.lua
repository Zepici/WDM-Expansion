local terminal_drain = {}

local DRAIN_PREFIX = "wdm-terminal-drain-"
local TERMINAL_NAMES = {"wdm_terminal-1", "wdm_terminal-2", "wdm_terminal-3", "wdm_terminal-4", 
                        "wdm_terminal-5", "wdm_terminal-6", "wdm_terminal-7", "wdm_terminal-8"}
local DRAIN_NAMES = {"wdm-terminal-drain-1", "wdm-terminal-drain-2", "wdm-terminal-drain-3", "wdm-terminal-drain-4",
                     "wdm-terminal-drain-5", "wdm-terminal-drain-6", "wdm-terminal-drain-7", "wdm-terminal-drain-8"}

local function init_storage()
    storage.terminal_drain_by_force = storage.terminal_drain_by_force or {}
end

local function get_or_init_force_data(force_name)
    if not storage.terminal_drain_by_force[force_name] then
        storage.terminal_drain_by_force[force_name] = {
            level = 0,
            position = {x = 0, y = 0},
            registration = nil
        }
    end
    return storage.terminal_drain_by_force[force_name]
end

local function get_max_technology_level(force)
    if not force or not force.valid then return 0 end
    local max_level = 0
    for level = 1, 8 do
        local tech_name = "wdm_warp_drive_tech-" .. level
        if force.technologies[tech_name] and force.technologies[tech_name].researched then
            max_level = level
        end
    end
    return max_level
end

local function find_drain_at_position(surface, position)
    if not (surface and surface.valid) then return nil end
    local entities = surface.find_entities_filtered({
        position = position,
        radius = 0.1,
        name = DRAIN_NAMES
    })
    return entities and entities[1] or nil
end

local function destroy_drain_for_force(force_name)
    local force_data = get_or_init_force_data(force_name)
    local surface = game.surfaces[1]
    if surface and surface.valid then
        local drain = find_drain_at_position(surface, force_data.position)
        if drain and drain.valid then
            drain.destroy({raise_destroy = false})
        end
    end
    force_data.registration = nil
end

local function get_terminal_position_for_force(force)
    local surface = game.surfaces[1]
    if not (surface and surface.valid) then return {x = 0, y = 0} end
    
    for _, terminal_name in pairs(TERMINAL_NAMES) do
        local terminals = surface.find_entities_filtered({name = terminal_name, force = force})
        if terminals and #terminals > 0 then
            return terminals[1].position
        end
    end
    return {x = 0, y = 0}
end

local function create_drain_for_force(force_name, force, level)
    if level <= 0 then
        destroy_drain_for_force(force_name)
        get_or_init_force_data(force_name).level = 0
        return
    end

    destroy_drain_for_force(force_name)

    local drain_name = DRAIN_PREFIX .. level
    local surface = game.surfaces[1]
    if not (surface and surface.valid) then return end

    local position = get_terminal_position_for_force(force)
    if not position then position = {x = 0, y = 0} end
    
    local drain = surface.create_entity({
        name = drain_name,
        position = position,
        force = force,
        create_build_effect_smoke = false,
        raise_built = false
    })

    if drain and drain.valid then
        drain.destructible = false
        drain.operable = false
        drain.minable = false
        
        local force_data = get_or_init_force_data(force_name)
        force_data.level = level
        force_data.position = {x = drain.position.x, y = drain.position.y}
        force_data.registration = script.register_on_object_destroyed(drain)
    end
end

local function update_drain_for_force(force_name, force)
    if not force or not force.valid then return end
    local max_level = get_max_technology_level(force)
    local force_data = get_or_init_force_data(force_name)
    if max_level ~= force_data.level then
        create_drain_for_force(force_name, force, max_level)
    end
end

function terminal_drain.on_init_or_configuration_changed()
    init_storage()
    for _, force in pairs(game.forces) do
        update_drain_for_force(force.name, force)
    end
end

function terminal_drain.on_load()
end

function terminal_drain.on_technology_researched(event)
    if not event or not event.research then return end
    local research = event.research
    local force = research.force
    if not force or not force.valid then return end
    
    local tech_name = research.name
    if string.match(tech_name, "^wdm_warp_drive_tech%-[1-8]$") then
        update_drain_for_force(force.name, force)
    end
end

function terminal_drain.on_object_destroyed(event)
    init_storage()
    if not event or not event.registration_number then return end
    
    for force_name, force_data in pairs(storage.terminal_drain_by_force) do
        if force_data.registration == event.registration_number then
            force_data.registration = nil
            force_data.level = 0
            return
        end
    end
end

function terminal_drain.on_entity_built(event)
    init_storage()
    local entity = event.entity or event.created_entity or event.destination or event.cloned_entity
    if not entity or not entity.valid then return end
    
    -- Если построили терминал, переместим потребителя той же силы к нему
    for _, terminal_name in pairs(TERMINAL_NAMES) do
        if entity.name == terminal_name then
            local force_data = get_or_init_force_data(entity.force.name)
            if force_data.level > 0 then
                destroy_drain_for_force(entity.force.name)
                local surface = game.surfaces[1]
                if surface and surface.valid then
                    local drain_name = DRAIN_PREFIX .. force_data.level
                    local drain = surface.create_entity({
                        name = drain_name,
                        position = entity.position,
                        force = entity.force,
                        create_build_effect_smoke = false,
                        raise_built = false
                    })
                    if drain and drain.valid then
                        drain.destructible = false
                        drain.operable = false
                        drain.minable = false
                        force_data.position = {x = drain.position.x, y = drain.position.y}
                        force_data.registration = script.register_on_object_destroyed(drain)
                    end
                end
            end
            return
        end
    end
end

return terminal_drain
