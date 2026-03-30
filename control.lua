local planetary_events = require("script.planetary_events")
local heat_pipes = require("script.heat_pipes")
local turret_buff = require("script.turret_buff")
local emergency_return = require("script.emergency_return")
local wdm_blueprints_overrides = require("script.wdm_blueprints_overrides")

emergency_return.init({
    find_safe_teleport_position = planetary_events.find_safe_teleport_position
})

local function safe_call(fn, event)
    if not fn then return end
    pcall(function()
        fn(event)
    end)
end

local function on_entity_built(event)
    safe_call(heat_pipes.on_entity_built, event)
    safe_call(planetary_events.on_entity_built, event)
    safe_call(turret_buff.on_entity_built, event)
end

local function on_entity_removed(event)
    safe_call(heat_pipes.on_entity_removed, event)
    safe_call(planetary_events.on_entity_removed, event)
    safe_call(turret_buff.on_entity_removed, event)
end

local function register_shared_event_handlers()
    script.on_event(defines.events.on_built_entity, on_entity_built)
    script.on_event(defines.events.on_robot_built_entity, on_entity_built)
    script.on_event(defines.events.script_raised_built, on_entity_built)
    script.on_event(defines.events.script_raised_revive, on_entity_built)

    if defines.events.on_space_platform_built_entity then
        script.on_event(defines.events.on_space_platform_built_entity, on_entity_built)
    end

    script.on_event(defines.events.on_entity_died, on_entity_removed)
    script.on_event(defines.events.on_player_mined_entity, on_entity_removed)
    script.on_event(defines.events.on_robot_mined_entity, on_entity_removed)
    script.on_event(defines.events.script_raised_destroy, on_entity_removed)

    if defines.events.on_space_platform_mined_entity then
        script.on_event(defines.events.on_space_platform_mined_entity, on_entity_removed)
    end

    script.on_event(defines.events.on_player_built_tile, turret_buff.on_tiles_changed)
    script.on_event(defines.events.on_robot_built_tile, turret_buff.on_tiles_changed)
    script.on_event(defines.events.on_player_mined_tile, turret_buff.on_tiles_changed)
    script.on_event(defines.events.on_robot_mined_tile, turret_buff.on_tiles_changed)
    script.on_event(defines.events.script_raised_set_tiles, turret_buff.on_tiles_changed)

    script.on_event(defines.events.on_player_used_capsule, emergency_return.on_player_used_capsule)
end

local function register_wdm_blueprint_overrides()
    return wdm_blueprints_overrides.register_wdm_blueprint_overrides()
end

local function on_wdm_pirate_ship_spawned(_event)
    register_wdm_blueprint_overrides()
end

local function register_wdm_pirate_ship_spawned_handler()
    if not remote.interfaces["WDM"] then return false end
    local ok, event_id = pcall(function()
        return remote.call("WDM", "get_on_pirate_ship_spawned")
    end)
    if ok and event_id then
        script.on_event(event_id, on_wdm_pirate_ship_spawned)
        return true
    end
    return false
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    safe_call(planetary_events.on_runtime_mod_setting_changed, event)
    safe_call(turret_buff.on_runtime_mod_setting_changed, event)
    register_wdm_blueprint_overrides()
    register_wdm_pirate_ship_spawned_handler()
end)

script.on_init(function()
    planetary_events.initialize_mod()
    heat_pipes.on_init_or_configuration_changed()
    turret_buff.on_init_or_configuration_changed()
    register_wdm_blueprint_overrides()
    register_wdm_pirate_ship_spawned_handler()
    register_shared_event_handlers()
end)

script.on_configuration_changed(function(_cfg)
    planetary_events.initialize_mod()
    heat_pipes.on_init_or_configuration_changed()
    turret_buff.on_init_or_configuration_changed()
    register_wdm_blueprint_overrides()
    register_wdm_pirate_ship_spawned_handler()
    register_shared_event_handlers()
end)

script.on_load(function()
    planetary_events.on_load()
    heat_pipes.on_load()
    register_wdm_pirate_ship_spawned_handler()
    register_shared_event_handlers()
end)
