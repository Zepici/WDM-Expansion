local planetary_events = require("script.planetary_events")
local heat_pipes = require("script.heat_pipes")
local turret_buff = require("script.turret_buff")
local emergency_return = require("script.emergency_return")
local wdm_blueprints_overrides = require("script.wdm_blueprints_overrides")
local change_events = require("script.change_events")
local terminal_drain = require("script.terminal_drain")
local mind_control = require("script.mind_control")
local ship_abilities = require("script.ship_abilities")
local ship_abilities_gui = require("script.ship_abilities_gui")
local mod_commands = require("script.commands")

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
    safe_call(terminal_drain.on_entity_built, event)
    safe_call(ship_abilities.on_entity_built, event)
end

local function on_entity_cloned(event)
    safe_call(heat_pipes.on_entity_cloned, event)
    safe_call(ship_abilities.on_entity_cloned, event)
end

local function on_entity_removed(event)
    safe_call(heat_pipes.on_entity_removed, event)
    safe_call(planetary_events.on_entity_removed, event)
    safe_call(turret_buff.on_entity_removed, event)
    safe_call(ship_abilities.on_entity_removed, event)
end

local function on_object_destroyed(event)
    safe_call(heat_pipes.on_object_destroyed, event)
    safe_call(planetary_events.on_object_destroyed, event)
    safe_call(terminal_drain.on_object_destroyed, event)
    safe_call(ship_abilities.on_object_destroyed, event)
end

local function on_surface_deleted(event)
    safe_call(planetary_events.on_surface_deleted, event)
end

local function on_chunk_generated(event)
    safe_call(planetary_events.on_chunk_generated, event)
end

local function sync_chunk_generated_handler()
    local enabled = false
    if planetary_events and planetary_events.should_enable_chunk_generated_handler then
        local ok, value = pcall(function()
            return planetary_events.should_enable_chunk_generated_handler()
        end)
        enabled = ok and value or false
    end

    if enabled then
        script.on_event(defines.events.on_chunk_generated, on_chunk_generated)
    else
        script.on_event(defines.events.on_chunk_generated, nil)
    end
end

local function register_shared_event_handlers()
    script.on_event(defines.events.on_built_entity, on_entity_built)
    script.on_event(defines.events.on_robot_built_entity, on_entity_built)
    script.on_event(defines.events.on_entity_cloned, on_entity_built)
    script.on_event(defines.events.script_raised_built, on_entity_built)
    script.on_event(defines.events.script_raised_revive, on_entity_built)
    script.on_event(defines.events.on_entity_cloned, on_entity_cloned)
    if defines.events.on_space_platform_built_entity then
        script.on_event(defines.events.on_space_platform_built_entity, on_entity_built)
    end

--    script.on_event(defines.events.on_entity_died, on_entity_removed)
    script.on_event(
        defines.events.on_post_entity_died,
        turret_buff.on_post_entity_died,
        turret_buff.get_post_entity_died_filters()
    )
    script.on_event(defines.events.on_player_mined_entity, on_entity_removed)
    script.on_event(defines.events.on_robot_mined_entity, on_entity_removed)
    script.on_event(defines.events.script_raised_destroy, on_entity_removed)
    script.on_event(defines.events.on_object_destroyed, on_object_destroyed)

    if defines.events.on_space_platform_mined_entity then
        script.on_event(defines.events.on_space_platform_mined_entity, on_entity_removed)
    end

    script.on_event(defines.events.on_player_built_tile, turret_buff.on_tiles_changed)
    script.on_event(defines.events.on_robot_built_tile, turret_buff.on_tiles_changed)
    script.on_event(defines.events.on_player_mined_tile, turret_buff.on_tiles_changed)
    script.on_event(defines.events.on_robot_mined_tile, turret_buff.on_tiles_changed)
    script.on_event(defines.events.script_raised_set_tiles, turret_buff.on_tiles_changed)

    script.on_event(defines.events.on_player_used_capsule, emergency_return.on_player_used_capsule)

    script.on_event(defines.events.on_research_finished, function(event)
        safe_call(terminal_drain.on_technology_researched, event)
    end)

    -- GUI events
    script.on_event(defines.events.on_gui_click, function(event)
        safe_call(ship_abilities_gui.on_gui_click, event)
        safe_call(planetary_events.on_gas_leak_gui_click, event)
    end)
    
    script.on_event(defines.events.on_gui_opened, function(event)
        ship_abilities.on_gui_opened(event)
        if event.gui_type == defines.gui_type.entity and event.entity and event.entity.valid then
            if event.entity.name == "wdm-ship-abilities-console" then
                local player = game.get_player(event.player_index)
                if player then
                    player.opened = nil
                    ship_abilities_gui.open_console(player, event.entity)
                end
                return
            end
        end
    end)

    -- Mind control system
    script.on_event(defines.events.on_script_trigger_effect, mind_control.on_script_trigger_effect)

    if defines.events.on_pre_surface_deleted then
        script.on_event(defines.events.on_pre_surface_deleted, on_surface_deleted)
    elseif defines.events.on_surface_deleted then
        script.on_event(defines.events.on_surface_deleted, on_surface_deleted)
    end
    
    -- Handle choose-elem-button changes (waste recycler item selection)
--    script.on_event(defines.events.on_gui_elem_changed, function(event)
--        safe_call(ship_abilities_gui.on_gui_elem_changed, event)
--    end)
    
    script.on_event(defines.events.on_gui_closed, function(event)
        safe_call(ship_abilities_gui.on_gui_closed, event)
    end)
end

local function register_wdm_blueprint_overrides()
    return wdm_blueprints_overrides.register_wdm_blueprint_overrides()
end

local function randomize_wdm_blueprint_overrides()
    return wdm_blueprints_overrides.randomize_wdm_blueprint_overrides()
end

local function apply_wdm_blueprint_overrides()
    return wdm_blueprints_overrides.apply_wdm_blueprint_overrides()
end

local function on_wdm_pirate_ship_spawned(_event)
    register_wdm_blueprint_overrides()
end

mod_commands.register({
    planetary_events = planetary_events,
    register_wdm_blueprint_overrides = register_wdm_blueprint_overrides
})

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
    sync_chunk_generated_handler()
end)

script.on_init(function()
    planetary_events.initialize_mod()
    heat_pipes.on_init_or_configuration_changed()
    turret_buff.on_init_or_configuration_changed()
    terminal_drain.on_init_or_configuration_changed()
    change_events.apply_default_event_overrides()
    mind_control.on_init()
    ship_abilities.init()
    randomize_wdm_blueprint_overrides()
    apply_wdm_blueprint_overrides()
    register_wdm_pirate_ship_spawned_handler()
    register_shared_event_handlers()
    sync_chunk_generated_handler()
    -- Привязываем ship_abilities.on_ship_post_warp к planetary_events (единая регистрация on_ship_post_warp)
    planetary_events.set_external_ship_post_warp_handler(ship_abilities.on_ship_post_warp)
end)

script.on_configuration_changed(function(_cfg)
    planetary_events.initialize_mod()
    heat_pipes.on_init_or_configuration_changed()
    turret_buff.on_init_or_configuration_changed()
    terminal_drain.on_init_or_configuration_changed()
    change_events.apply_default_event_overrides()
    ship_abilities.init()
    register_wdm_blueprint_overrides()
    register_wdm_pirate_ship_spawned_handler()
    register_shared_event_handlers()
    sync_chunk_generated_handler()
    -- Привязываем ship_abilities.on_ship_post_warp к planetary_events (единая регистрация on_ship_post_warp)
    planetary_events.set_external_ship_post_warp_handler(ship_abilities.on_ship_post_warp)
end)

script.on_load(function()
    planetary_events.on_load()
    heat_pipes.on_load()
    terminal_drain.on_load()
    mind_control.on_load()
    ship_abilities.on_load()
    ship_abilities_gui.on_load()
    register_wdm_pirate_ship_spawned_handler()
    register_shared_event_handlers()
    sync_chunk_generated_handler()
    -- Привязываем ship_abilities.on_ship_post_warp к planetary_events (единая регистрация on_ship_post_warp)
    planetary_events.set_external_ship_post_warp_handler(ship_abilities.on_ship_post_warp)
    ship_abilities.update_ticker_state()
end)
