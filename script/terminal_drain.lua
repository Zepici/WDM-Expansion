local terminal_drain = {}

local DRAIN_PREFIX = "wdm-terminal-drain-"

local TERMINAL_NAMES = {
    "wdm_terminal-1", "wdm_terminal-2", "wdm_terminal-3", "wdm_terminal-4", 
    "wdm_terminal-5", "wdm_terminal-6", "wdm_terminal-7", "wdm_terminal-8", "wdm_destroyed_terminal"
}
local DRAIN_NAMES = {
    "wdm-terminal-drain-0", "wdm-terminal-drain-1", "wdm-terminal-drain-2", "wdm-terminal-drain-3", 
    "wdm-terminal-drain-4", "wdm-terminal-drain-5", "wdm-terminal-drain-6", "wdm-terminal-drain-7", "wdm-terminal-drain-8"
}

local function init_storage()
    storage.terminal_drain_by_force = storage.terminal_drain_by_force or {}
end

local function get_or_init_force_data(force_name)
    if not storage.terminal_drain_by_force[force_name] then
        storage.terminal_drain_by_force[force_name] = {
            level = -1, 
            position = {x = 0, y = 0},
            surface_index = 1, 
            ent = nil,
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

local function destroy_drain_for_force(force_name, destination_surface)
    local force_data = get_or_init_force_data(force_name)
    if force_data.ent and force_data.ent.valid then
        force_data.ent.destroy({raise_destroy = false})
    end

    local surfaces_to_check = {}
    
    local old_surface = game.surfaces[force_data.surface_index]
    if old_surface and old_surface.valid then
        table.insert(surfaces_to_check, old_surface)
    end
    if destination_surface and destination_surface.valid and destination_surface.index ~= force_data.surface_index then
        table.insert(surfaces_to_check, destination_surface)
    end
    for _, surface in pairs(surfaces_to_check) do
        local old_drains = surface.find_entities_filtered({
            position = force_data.position,
            radius = 5.0,
            name = DRAIN_NAMES,
            force = force_name
        })
        for _, old_drain in pairs(old_drains) do
            if old_drain.valid then old_drain.destroy({raise_destroy = false}) end
        end
    end

    force_data.ent = nil
    force_data.registration = nil
end

local function get_terminal_info_for_force(force, preferred_surface)
    if preferred_surface and preferred_surface.valid then
        for _, terminal_name in pairs(TERMINAL_NAMES) do
            local terminals = preferred_surface.find_entities_filtered({name = terminal_name, force = force})
            if terminals and #terminals > 0 then
                return terminals[1].position, preferred_surface
            end
        end
    end
    return nil, nil
end

local function create_drain_for_force(force_name, force, level, target_surface)
    destroy_drain_for_force(force_name, target_surface)

    local position, surface = get_terminal_info_for_force(force, target_surface)
    if not position or not surface then 
        local force_data = get_or_init_force_data(force_name)
        force_data.level = level
        return 
    end
    
    local drain_name = DRAIN_PREFIX .. level
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
        force_data.surface_index = surface.index
        force_data.ent = drain
        force_data.registration = script.register_on_object_destroyed(drain)
    end
end

local function update_drain_for_force(force_name, force)
    if not force or not force.valid then return end
    local max_level = get_max_technology_level(force)
    local force_data = get_or_init_force_data(force_name)
    
    local drain_exists = (force_data.ent and force_data.ent.valid) and true or false
    local current_surface = game.surfaces[force_data.surface_index]

    if max_level ~= force_data.level or not drain_exists then
        create_drain_for_force(force_name, force, max_level, current_surface)
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
            force_data.ent = nil
            force_data.level = 0
            return
        end
    end
end

function terminal_drain.on_entity_built(event)
    init_storage()
    local entity = event.entity or event.created_entity or event.destination or event.cloned_entity
    if not entity or not entity.valid then return end
    
    for _, terminal_name in pairs(TERMINAL_NAMES) do
        if entity.name == terminal_name then
            local force_data = get_or_init_force_data(entity.force.name)
            
            if force_data.level == -1 then
                force_data.level = get_max_technology_level(entity.force)
            end

            if force_data.level >= 0 then 
                local surface = entity.surface
                if surface and surface.valid then
                    create_drain_for_force(entity.force.name, entity.force, force_data.level, surface)
                end
            end
            return
        end
    end
end

function terminal_drain.on_ship_warped_handler(force_name, force, destination_surface)
    if not force or not force.valid then return end
    local max_level = get_max_technology_level(force)
    create_drain_for_force(force_name, force, max_level, destination_surface)
end

return terminal_drain
