-- Made by ZepCannon
local util = require("util")
local terminal_drain = require("script.terminal_drain")

local function has_active_mod(mod_name)
    return script and script.active_mods and script.active_mods[mod_name] ~= nil
end
local HAS_SPACE_AGE = has_active_mod("space-age")
local HAS_ZOMBIE_HORDE = has_active_mod("ZombieHordeFaction")

-- ============================================================
-- КОНСТАНТЫ И КОНФИГУРАЦИЯ
-- ============================================================

local DEFAULT_TECH_TIERS

if has_active_mod("space-age") then
    -- Space Age
    DEFAULT_TECH_TIERS = {
        {"logistic-science-pack"},
        {"chemical-science-pack"},
        {"production-science-pack", "utility-science-pack"},
        {"agricultural-science-pack", "electromagnetic-science-pack", "metallurgic-science-pack"}
    }
else
    -- no Space Age
    DEFAULT_TECH_TIERS = {
        {"logistic-science-pack"},
        {"chemical-science-pack"},
        {"production-science-pack", "utility-science-pack"},
        {"space-science-pack"}
    }
end

-- Конфигурация событий по умолчанию
local RUINS_BLUEPRINT_POOL
local DEFAULT_EVENTS = {
    laser_boss = {
        prototype = nil,
        -- WDM planet event parameters
        wdm_chance = 0.08,
        wdm_min_wap = 40,
        wdm_must_have_on = 25,
        wdm_min_tech_progress = 0.1,
        wdm_no_repeat = true,
        wdm_requires_enemies = true,
        wdm_can_be_removed = false,
        wdm_difficulty_add = 0.01,
        wdm_alarm = true,
        -- Internal config
        action_name = "spawn_laser_boss_far",
        spawn_count = 1,
        spawn_distance_modifier = 1,
        spawn_opts = {
            spacing = 100,
            elite_chance = HAS_SPACE_AGE and 0.2 or 0
        },
        waves = { min = 1, max = 3 },
        wave_min_delay_seconds = 30,
        wave_max_delay_seconds = 120,
        tech_influence = 0.6
    },
    earthquake = {
        -- WDM planet event parameters
        wdm_chance = 0.12,
        wdm_min_wap = 10,
        wdm_min_tech_progress = 0,
        wdm_no_repeat = false,
        wdm_requires_enemies = false,
        wdm_can_be_removed = false,
        wdm_difficulty_add = 0.0,
        wdm_alarm = true,
        -- Internal config
        action_name = "earthquake",
        speed_reduction = -0.4,
        duration_seconds = 180,
        tech_influence = 0.7
    },
    lost_deck = {
        -- WDM planet event parameters
        wdm_chance = 0.10,
        wdm_min_wap = 35,
        wdm_min_tech_progress = 0.1,
        wdm_no_repeat = false,
        wdm_requires_enemies = false,
        wdm_can_be_removed = true,
        wdm_difficulty_add = 0.0,
        wdm_alarm = true,
        -- Internal config
        action_name = "lost_deck",
        duration_seconds = 240,
        tech_influence = 0.7
    },
    --[[
    pirate_attack = {
        spawn_chance = 0.1,
        min_wap = 2,
        delay_ticks = 10,
        action_name = "spawn_pirate_base"
    },
    ]]
    crystal_overgrowth = {
        -- WDM planet event parameters
        wdm_chance = 0.06,
        wdm_min_wap = 30,
        wdm_min_tech_progress = 0,
        wdm_must_have_on = 33,
        wdm_no_repeat = true,
        wdm_requires_enemies = true,
        wdm_can_be_removed = false,
        wdm_difficulty_add = 0.02,
        wdm_alarm = true,
        -- Internal config
        action_name = "crystal_overgrowth",
        initial_count = 3,
        growth_count = 3,
        growth_interval_seconds = 120,
        big_crystal_chance = 0.072,
        big_crystal_bonus = 0.75,
        enemy_bonus_per_crystal = 0.15, -- additive per mined crystal
        spawn_distance_modifier = 1
    },
    bright_day = {
        -- WDM planet event parameters
        wdm_chance = 0.13,
        wdm_min_wap = 10,
        wdm_min_tech_progress = 0,
        wdm_no_repeat = false,
        wdm_requires_enemies = false,
        wdm_can_be_removed = false,
        wdm_difficulty_add = 0.0,
        wdm_alarm = false,
        -- Internal config
        action_name = "bright_day",
        solar_multiplier = 2.0,
        daytime_ratio = 0.8
    },
    has_boss_2 = {
        -- WDM planet event parameters
        wdm_chance = 0.09,
        wdm_min_wap = 60,
        wdm_must_have_on = 20,
        wdm_min_tech_progress = 0.2,
        wdm_no_repeat = true,
        wdm_requires_enemies = true,
        wdm_can_be_removed = false,
        wdm_difficulty_add = 0.015,
        wdm_alarm = true,
        wdm_min_delay = 300,
        wdm_max_delay = 480,
        -- Internal config
        action_name = "spawn_boss_at_world_edge",
        spawn_count = 1,
        edge_distance_from_ship = 300,
        spawn_opts = {
            spacing = 120,
        },
        tech_influence = 0.55
    },
    ruins = {
        -- WDM planet event parameters
        wdm_chance = 0.065,
        wdm_min_wap = 30,
        wdm_min_tech_progress = 0,
        wdm_no_repeat = true,
        wdm_requires_enemies = false,
        wdm_can_be_removed = false,
        wdm_difficulty_add = 0.0,
        wdm_alarm = false,
        -- Internal config
        action_name = "ruins",
        chunk_spawn_chance = 0.008,
        spawn_attempts = 2,
        blueprint_pool = RUINS_BLUEPRINT_POOL,
        tech_influence = 0.4
    },
    gas_leak = {
        -- WDM planet event parameters
        wdm_chance = 1,
        wdm_min_wap = 0,
        wdm_min_tech_progress = 0,
        wdm_no_repeat = true,
        wdm_requires_enemies = false,
        wdm_can_be_removed = true,
        wdm_difficulty_add = 0.01,
        wdm_alarm = true,
        -- Internal config
        action_name = "gas_leak",
        initial_clouds_per_floor = 3,
        cloud_growth_interval_seconds = 30,
        cloud_growth_count = 2,
        repair_items_count = 4,
        item_pool = {
            {name = "electronic-circuit", count_min = 30, count_max = 120},
            {name = "iron-plate", count_min = 120, count_max = 480},
            {name = "copper-plate", count_min = 110, count_max = 440},
            {name = "steel-plate", count_min = 30, count_max = 120},
            {name = "pipe", count_min = 25, count_max = 100},
            {name = "copper-cable", count_min = 50, count_max = 200},
            {name = "stone-brick", count_min = 30, count_max = 120},
            {name = "plastic-bar", count_min = 40, count_max = 160}
        }
    }
}

if has_active_mod("Krastorio2-spaced-out") or has_active_mod("Krastorio2") then
    table.insert(DEFAULT_EVENTS.gas_leak.item_pool, {name = "kr-glass", count_min = 20, count_max = 80})
    table.insert(DEFAULT_EVENTS.gas_leak.item_pool, {name = "kr-electronic-components", count_min = 120, count_max = 240})
end

if has_active_mod("magnetic-storm") then
    DEFAULT_EVENTS.electromagnetic_storm = {
        -- WDM planet event parameters
        wdm_chance = 0.08,
        wdm_min_wap = 20,
        wdm_min_tech_progress = 0.1,
        wdm_must_have_on = 25,
        wdm_no_repeat = true,
        wdm_requires_enemies = false,
        wdm_can_be_removed = false,
        wdm_difficulty_add = 0.015,
        wdm_alarm = true,
        -- Internal config
        action_name = "electromagnetic_storm",
        duration_threat_weight = 1.0,
        storm_min = 21,
        storm_max = 100,
        tech_influence = 0.7
    }
end

-- ============================================================
-- УТИЛИТЫ И ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================

local function is_mod_enabled()
    if not settings.startup then return true end
    local setting = settings.startup["wdm-expansion-event-enable"]
    if setting ~= nil then 
        return setting.value 
    end
    return true 
end

local function is_debug_enabled()
    if not settings.global then return false end
    local setting = settings.global["wdm-expansion-debug"]
    if setting then return setting.value end
    return false
end

local function is_friendly_fire_disabled()
    if not settings.global then return false end
    local setting = settings.global["wdm-expansion-disable-friendly-fire"]
    if setting then return setting.value end
    return false
end

local function debug(msg)
    if not game then return end
    if not is_debug_enabled() then return end
    log("[WDM Expansion DEBUG] " .. msg)
    for _, p in pairs(game.connected_players) do
        p.print("[WDM Expansion DEBUG] " .. msg)
    end
end

local function apply_turret_delay(entity, delay_seconds)
    if not (entity and entity.valid) then return end
    if not (remote and remote.interfaces and remote.interfaces["Turret_Delay"]) then return end

    pcall(function()
        remote.call("Turret_Delay", "entity_delay_activation", entity, delay_seconds)
    end)
end

local function ensure_turret_delay_artillery_support()
    if not (remote and remote.interfaces and remote.interfaces["Turret_Delay"]) then return end

    pcall(function()
        remote.call("Turret_Delay", "add_turret_name", "artillery-turret")
    end)
end

local function apply_artillery_turret_delay(entity)
    if not (entity and entity.valid) then return end
    if entity.name ~= "artillery-turret" then return end
    apply_turret_delay(entity, 10)
end

local function table_size(t)
    if not t then return 0 end
    local cnt = 0
    for _ in pairs(t) do cnt = cnt + 1 end
    return cnt
end

local function distance(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

local function clamp(value, min_value, max_value)
    if value < min_value then return min_value end
    if value > max_value then return max_value end
    return value
end

local function is_non_water_tile(surface, position)
    if not (surface and surface.valid and position) then return false end

    local ok, tile = pcall(function()
        return surface.get_tile(position)
    end)
    if not (ok and tile and tile.valid and tile.name) then return false end
    if tile.name == "out-of-map" then return false end

    local collides_ok, is_water = pcall(function()
        return tile.collides_with("water-tile")
    end)
    if collides_ok then
        return not is_water
    end

    return not string.find(tile.name, "water", 1, true)
end

local function get_magnetic_storm_value(surface)
    if not (surface and surface.valid and surface.get_property) then return nil end
    local ok, val = pcall(function() return surface.get_property("magnetic-storm") end)
    if ok and type(val) == "number" then return val end
    return nil
end

local function set_magnetic_storm_value(surface, value)
    if not (surface and surface.valid and surface.set_property) then return false end
    return pcall(function() surface.set_property("magnetic-storm", value) end)
end

local function play_storm_state_change_sound(surface)
    if not game then return end

    pcall(function()
        game.play_sound{
            path = "wdm-magnetic-storm-state-change",
            volume_modifier = 0.8
        }
    end)
end

local STORM_REDUCTION_TRIGGER_VALUE = 50
local STORM_REDUCTION_VALUE = 40
local STORM_REDUCTION_INTERVAL_TICKS = 80 * 60
local STORM_REDUCTION_DURATION_TICKS = 20 * 60

local STORM_DISABLE_THRESHOLDS_BY_TYPE = {
--    ["accumulator"] = 25,
--    ["solar-panel"] = 45,
    ["generator"] = 55,
    ["fusion-generator"] = 65
--    ["electric-pole"] = 75
}

local STORM_DISABLE_ENTITY_TYPES = {
    "accumulator",
    "solar-panel",
    "generator",
    "fusion-generator",
    "electric-pole"
} 

local STORM_DISABLE_EXCLUDED_NAMES = {
    ["ring-teleporter"] = true
}

local function get_storm_disable_threshold(entity)
    if not (entity and entity.valid) then return nil end
    if STORM_DISABLE_EXCLUDED_NAMES[entity.name] then return nil end
    return STORM_DISABLE_THRESHOLDS_BY_TYPE[entity.type]
end

local function get_storm_surface_cache(surface_index, create_if_missing)
    storage.storm_tracked_entities = storage.storm_tracked_entities or {}
    local cache = storage.storm_tracked_entities[surface_index]
    if (not cache) and create_if_missing then
        cache = {
            all = {},
            tracked_by_threshold = {},
            currently_disabled = {},
            needs_refresh = false
        }
        storage.storm_tracked_entities[surface_index] = cache
    end
    return cache
end

local function init_storm_destroy_registrations()
    storage.storm_destroy_registrations = storage.storm_destroy_registrations or {
        by_registration = {}, -- [registration_number] = {surface_index, key}
        by_key = {} -- [key] = registration_number
    }
end

local function make_storm_entity_record_key(entity)
    if entity.unit_number then
        return "u:" .. tostring(entity.unit_number)
    end
    local pos = entity.position
    return table.concat({
        "p",
        entity.name or "?",
        string.format("%.3f", pos.x),
        string.format("%.3f", pos.y)
    }, ":")
end

local function make_storm_entity_record(entity)
    local pos = entity.position
    return {
        key = make_storm_entity_record_key(entity),
        entity = entity,
        threshold = get_storm_disable_threshold(entity),
        name = entity.name,
        position = { x = pos.x, y = pos.y },
        unit_number = entity.unit_number
    }
end

local function unregister_storm_destroy_registration_by_key(key)
    if not (storage and storage.storm_destroy_registrations and key) then return end
    local registrations = storage.storm_destroy_registrations
    local registration_number = registrations.by_key[key]
    if registration_number then
        registrations.by_key[key] = nil
        registrations.by_registration[registration_number] = nil
    end
end

local function register_storm_destroy_tracking(entity, record)
    if not (entity and entity.valid and record and record.key) then return end
    init_storm_destroy_registrations()

    local registrations = storage.storm_destroy_registrations
    local existing = registrations.by_key[record.key]
    if existing then
        registrations.by_registration[existing] = {
            surface_index = entity.surface.index,
            key = record.key
        }
        return
    end

    local registration_number = script.register_on_object_destroyed(entity)
    if registration_number then
        registrations.by_key[record.key] = registration_number
        registrations.by_registration[registration_number] = {
            surface_index = entity.surface.index,
            key = record.key
        }
    end
end

local function add_storm_tracked_entity(entity)
    if not (entity and entity.valid and entity.surface and entity.surface.valid) then return nil end

    local threshold = get_storm_disable_threshold(entity)
    if not threshold then return nil end

    local cache = get_storm_surface_cache(entity.surface.index, true)
    local key = make_storm_entity_record_key(entity)
    local existing = cache.all[key]
    if existing then
        existing.entity = entity
        existing.threshold = threshold
        register_storm_destroy_tracking(entity, existing)
        return existing, threshold
    end

    local record = make_storm_entity_record(entity)
    cache.all[key] = record
    cache.tracked_by_threshold[threshold] = cache.tracked_by_threshold[threshold] or {}
    cache.tracked_by_threshold[threshold][key] = record
    register_storm_destroy_tracking(entity, record)
    return record, threshold
end

local function refresh_storm_entity_cache_for_surface(surface, force_rebuild)
    if not (surface and surface.valid) then return nil end

    local cache = get_storm_surface_cache(surface.index, true)
    local needs_rebuild = force_rebuild or cache.needs_refresh or (not next(cache.all))

    if needs_rebuild then
        cache.all = {}
        cache.tracked_by_threshold = {}
        cache.currently_disabled = {}
        cache.needs_refresh = false
    else
        return cache
    end

    for _, entity_type in ipairs(STORM_DISABLE_ENTITY_TYPES) do
        local entities = surface.find_entities_filtered { type = entity_type }
        for _, entity in ipairs(entities) do
            add_storm_tracked_entity(entity)
        end
    end

    return cache
end

local function ensure_storm_entity_cache_for_surface(surface)
    if not (surface and surface.valid) then return nil end
    return refresh_storm_entity_cache_for_surface(surface, false)
end

local function set_entity_disabled_by_storm(entity, should_disable)
    if not (entity and entity.valid and entity.is_updatable) then return false, false end
    local current = entity.disabled_by_script or false
    if current == should_disable then
        return true, false
    end
    entity.disabled_by_script = should_disable
    return true, true
end

local function apply_storm_state_to_record(surface_index, cache, record, should_disable)
    if not (cache and record) then return end

    local entity = record.entity
    if not (entity and entity.valid and entity.surface and entity.surface.valid and entity.surface.index == surface_index) then
        cache.needs_refresh = true
        cache.all[record.key] = nil
        local threshold_bucket = cache.tracked_by_threshold[record.threshold]
        if threshold_bucket then
            threshold_bucket[record.key] = nil
            if not next(threshold_bucket) then
                cache.tracked_by_threshold[record.threshold] = nil
            end
        end
        cache.currently_disabled[record.key] = nil
        return
    end

    local ok, changed = set_entity_disabled_by_storm(entity, should_disable)
    if not ok then return end

    if should_disable then
        if changed or not cache.currently_disabled[record.key] then
            cache.currently_disabled[record.key] = record
        end
    else
        cache.currently_disabled[record.key] = nil
    end
end

local function apply_storm_disable_delta_on_surface(surface, previous_storm_value, storm_value)
    if not (surface and surface.valid) then return end
    local old_value = clamp(previous_storm_value or 0, 0, 100)
    local new_value = clamp(storm_value or 0, 0, 100)
    if old_value == new_value then return end

    local function apply_delta(cache)
        if new_value > old_value then
            for threshold, records in pairs(cache.tracked_by_threshold) do
                if old_value < threshold and new_value >= threshold then
                    for _, record in pairs(records) do
                        apply_storm_state_to_record(surface.index, cache, record, true)
                    end
                end
            end
        else
            local disabled = cache.currently_disabled
            local keys_to_enable = {}
            for key, record in pairs(disabled) do
                local threshold = record and record.threshold
                if threshold and old_value >= threshold and new_value < threshold then
                    keys_to_enable[#keys_to_enable + 1] = key
                end
            end
            for _, key in ipairs(keys_to_enable) do
                local record = disabled[key]
                if record then
                    apply_storm_state_to_record(surface.index, cache, record, false)
                end
            end
        end
    end

    local cache = ensure_storm_entity_cache_for_surface(surface)
    if not cache then return end
    apply_delta(cache)

    if cache.needs_refresh then
        cache = refresh_storm_entity_cache_for_surface(surface, true)
        if cache then
            apply_delta(cache)
        end
    end
end

local function sync_storm_disable_state_on_surface(surface, storm_value)
    if not (surface and surface.valid) then return end
    local value = clamp(storm_value or 0, 0, 100)

    local function sync_cache(cache)
        cache.currently_disabled = {}
        for threshold, records in pairs(cache.tracked_by_threshold) do
            local should_disable = value >= threshold
            for _, record in pairs(records) do
                apply_storm_state_to_record(surface.index, cache, record, should_disable)
            end
        end
    end

    local cache = ensure_storm_entity_cache_for_surface(surface)
    if not cache then return end
    sync_cache(cache)

    if cache.needs_refresh then
        cache = refresh_storm_entity_cache_for_surface(surface, true)
        if cache then
            sync_cache(cache)
        end
    end
end

local function remove_storm_disabled_record_for_entity(entity)
    if not (entity and entity.valid and entity.surface and entity.surface.valid) then return end
    local cache = get_storm_surface_cache(entity.surface.index, false)
    if not cache then return end
    cache.currently_disabled[make_storm_entity_record_key(entity)] = nil
end

local function remove_storm_records_by_key(surface_index, key)
    if not (surface_index and key) then return end
    local cache = get_storm_surface_cache(surface_index, false)
    if not cache then
        unregister_storm_destroy_registration_by_key(key)
        return
    end

    cache.currently_disabled[key] = nil

    local record = cache.all[key]
    if not record then
        unregister_storm_destroy_registration_by_key(key)
        if not next(cache.all) then
            storage.storm_tracked_entities[surface_index] = nil
        end
        return
    end

    cache.all[key] = nil
    local threshold_bucket = cache.tracked_by_threshold[record.threshold]
    if threshold_bucket then
        threshold_bucket[key] = nil
        if not next(threshold_bucket) then
            cache.tracked_by_threshold[record.threshold] = nil
        end
    end

    unregister_storm_destroy_registration_by_key(key)

    if not next(cache.all) then
        storage.storm_tracked_entities[surface_index] = nil
    end
end

local function remove_storm_tracked_record_for_entity(entity)
    if not (entity and entity.valid and entity.surface and entity.surface.valid) then return end
    local key = make_storm_entity_record_key(entity)
    remove_storm_records_by_key(entity.surface.index, key)
end

local function restore_storm_disabled_on_surface(surface_index)
    local cache = get_storm_surface_cache(surface_index, false)
    if not cache then return end

    local keys = {}
    for key in pairs(cache.currently_disabled) do
        keys[#keys + 1] = key
    end
    for _, key in ipairs(keys) do
        local record = cache.currently_disabled[key]
        if record and record.entity and record.entity.valid and record.entity.is_updatable then
            record.entity.disabled_by_script = false
        end
        cache.currently_disabled[key] = nil
    end
end

local function restore_all_storm_disabled_entities()
    if not (storage and storage.storm_tracked_entities and next(storage.storm_tracked_entities)) then return end
    local indices = {}
    for surface_index in pairs(storage.storm_tracked_entities) do
        table.insert(indices, surface_index)
    end
    for _, surface_index in ipairs(indices) do
        restore_storm_disabled_on_surface(surface_index)
    end
end

local function apply_storm_disable_to_built_entity(entity)
    if not (entity and entity.valid and entity.surface and entity.surface.valid) then return end
    local record = add_storm_tracked_entity(entity)

    local storms = storage and storage.active_magnetic_storms
    if not storms then return end
    local storm_data = storms[entity.surface.index]
    if not storm_data then return end

    local storm_value = storm_data.current_value
    if type(storm_value) ~= "number" then
        storm_value = storm_data.storm_value
    end
    if type(storm_value) ~= "number" then
        storm_value = get_magnetic_storm_value(entity.surface) or 0
    end

    if record and record.threshold then
        apply_storm_state_to_record(entity.surface.index, get_storm_surface_cache(entity.surface.index, true), record, storm_value >= record.threshold)
    end
end

local function rebuild_storm_destroy_registrations()
    init_storm_destroy_registrations()
    storage.storm_destroy_registrations.by_registration = {}
    storage.storm_destroy_registrations.by_key = {}

    for surface_index, cache in pairs(storage.storm_tracked_entities or {}) do
        if cache and cache.all then
            for key, record in pairs(cache.all) do
                local entity = record and record.entity
                if entity and entity.valid and entity.surface and entity.surface.valid then
                    register_storm_destroy_tracking(entity, record)
                else
                    remove_storm_records_by_key(surface_index, key)
                end
            end
        end
    end
end

-- ============================================================
-- STORAGE (EVENTS)
-- ============================================================

local function init_event_storage()
    storage.events = storage.events or {}
    storage.scheduled_events = storage.scheduled_events or {}
    storage.triggered_surface_events = storage.triggered_surface_events or {}
    storage.active_earthquakes = storage.active_earthquakes or {}
    storage.lost_decks = storage.lost_decks or {}
    storage.active_magnetic_storms = storage.active_magnetic_storms or {}
    storage.storm_tracked_entities = storage.storm_tracked_entities or {}
    init_storm_destroy_registrations()
    storage.crystal_overgrowth_active = storage.crystal_overgrowth_active or {}
    storage.crystal_overgrowth_blocked_zones = storage.crystal_overgrowth_blocked_zones or {}
    storage.ruins_active_surfaces = storage.ruins_active_surfaces or {}
    storage.ruins_trigger_force_by_surface = storage.ruins_trigger_force_by_surface or {}
    storage.ruins_blueprint_pool = storage.ruins_blueprint_pool or RUINS_BLUEPRINT_POOL
    storage.crystal_bonus_overrides = storage.crystal_bonus_overrides or {}
    storage.crystal_destroy_registrations = storage.crystal_destroy_registrations or {
        by_registration = {}, -- [registration_number] = {key, bonus_override}
        by_key = {} -- [key] = registration_number
    }
    storage.enemy_melee_damage_bonus = storage.enemy_melee_damage_bonus or 0
    storage.enemy_biological_damage_bonus = storage.enemy_biological_damage_bonus or 0
    storage.pirate_humanoid_damage_bonus = storage.pirate_humanoid_damage_bonus or 0
    storage.gas_leak_active = storage.gas_leak_active or {} -- [surface_index] = {active=true, clouds_count=0, growth_tick=0, repair_bounty=nil}
end

local function is_surface_event_repeat_persistent(event_name)
    return event_name == "bright_day" or event_name == "electromagnetic_storm" or event_name == "ruins"
end

local function get_triggered_surface_event_scope_key(surface, ship)
    if surface and surface.valid and surface.name then
        return "surface:" .. tostring(surface.name)
    end
    return nil
end

local function has_surface_event_been_triggered(surface, ship, event_name)
    local scope_key = get_triggered_surface_event_scope_key(surface, ship)
    if not (scope_key and event_name) then return false end
    local surface_events = storage.triggered_surface_events and storage.triggered_surface_events[scope_key]
    return surface_events and surface_events[event_name] or false
end

local function mark_surface_event_triggered(surface, ship, event_name)
    local scope_key = get_triggered_surface_event_scope_key(surface, ship)
    if not (scope_key and event_name) then return end
    storage.triggered_surface_events = storage.triggered_surface_events or {}
    storage.triggered_surface_events[scope_key] = storage.triggered_surface_events[scope_key] or {}
    storage.triggered_surface_events[scope_key][event_name] = true
end

local function clear_triggered_surface_events_for_surface_index(surface_index)
    if not (storage and storage.triggered_surface_events and surface_index) then return end
    storage.triggered_surface_events["surface-index:" .. tostring(surface_index)] = nil
end

local function clear_triggered_surface_events_for_surface_name(surface_name)
    if not (storage and storage.triggered_surface_events and surface_name) then return end
    storage.triggered_surface_events["surface:" .. tostring(surface_name)] = nil
end

local function cleanup_triggered_surface_events()
    if not (storage and storage.triggered_surface_events) then return end

    for scope_key, events in pairs(storage.triggered_surface_events) do
        local valid_scope = type(scope_key) == "string"
        if valid_scope and string.sub(scope_key, 1, 8) == "surface:" then
            local surface_name = string.sub(scope_key, 9)
            local surface = game and game.surfaces and game.surfaces[surface_name]
            valid_scope = surface and surface.valid
        elseif valid_scope and string.sub(scope_key, 1, 14) == "surface-index:" then
            local surface_index = tonumber(string.sub(scope_key, 15))
            local surface = surface_index and game and game.surfaces and game.surfaces[surface_index]
            valid_scope = surface and surface.valid
        elseif valid_scope and string.sub(scope_key, 1, 7) == "planet:" then
            valid_scope = true
        end

        if not valid_scope or not next(events or {}) then
            storage.triggered_surface_events[scope_key] = nil
        end
    end
end

local function get_wdm_revisit_event_chance(ev)
    if not ev then return 0 end

    local chance = tonumber(ev.wdm_chance) or 0
    local difficulty_add = tonumber(ev.wdm_difficulty_add) or 0
--    local difficulty_setting = settings.global and settings.global["wdm-difficulty-level"]
--    local difficulty_level = (difficulty_setting and tonumber(difficulty_setting.value)) or 0
    chance = chance + difficulty_add
--    chance = chance + (difficulty_add * difficulty_level)
    if chance < 0 then return 0 end
    if chance > 1 then return 1 end
    return chance
end

local function should_trigger_surface_event(surface, ship, event_name, ev)
    if not has_surface_event_been_triggered(surface, ship, event_name) then
        return true
    end

    if is_surface_event_repeat_persistent(event_name) then
        return true
    end

    local revisit_chance = get_wdm_revisit_event_chance(ev)
    local rolled = math.random()
    local success = rolled <= revisit_chance
    debug("Revisit roll for custom planet event '" .. tostring(event_name) .. "' on surface "
        .. tostring(surface and surface.name) .. ": rolled=" .. string.format("%.3f", rolled)
        .. ", chance=" .. string.format("%.3f", revisit_chance)
        .. ", success=" .. tostring(success))
    return success
end

local CRYSTAL_LOW_BONUS = 0.075
local SPECIAL_CRYSTAL_BONUS_TILES = {
    ["orange-refined-concrete"] = true,
    ["yellow-refined-concrete"] = true,
    ["cyan-refined-concrete"] = true,
    ["purple-refined-concrete"] = true,
    ["black-refined-concrete"] = true,
    ["red-refined-concrete"] = true,
    ["green-refined-concrete"] = true,
    ["blue-refined-concrete"] = true
}

local function make_crystal_bonus_key(entity)
    if not (entity and entity.valid and entity.surface and entity.surface.valid) then return nil end
    if entity.unit_number then
        return "u:" .. tostring(entity.unit_number)
    end
    local p = entity.position
    return table.concat({
        "p",
        tostring(entity.surface.index),
        string.format("%.3f", p.x),
        string.format("%.3f", p.y)
    }, ":")
end

local function get_crystal_bonus_override_value(entity)
    if not (entity and entity.valid and (entity.name == "entity-crystal" or entity.name == "big-crystal") and entity.surface and entity.surface.valid) then return end
    local ok, tile = pcall(function() return entity.surface.get_tile(entity.position) end)
    if not (ok and tile and tile.valid and tile.name and SPECIAL_CRYSTAL_BONUS_TILES[tile.name]) then return nil end
    return CRYSTAL_LOW_BONUS
end

local function clear_crystal_destroy_registration_by_key(key)
    if not (storage and storage.crystal_destroy_registrations and key) then return end
    local registrations = storage.crystal_destroy_registrations
    local registration_number = registrations.by_key[key]
    if registration_number then
        registrations.by_key[key] = nil
        registrations.by_registration[registration_number] = nil
    end
end

local function register_crystal_bonus_override(entity)
    if not (entity and entity.valid and (entity.name == "entity-crystal" or entity.name == "big-crystal") and entity.surface and entity.surface.valid) then return end
    storage.crystal_bonus_overrides = storage.crystal_bonus_overrides or {}
    storage.crystal_destroy_registrations = storage.crystal_destroy_registrations or {
        by_registration = {},
        by_key = {}
    }

    local key = make_crystal_bonus_key(entity)
    if not key then return end

    local bonus_override = get_crystal_bonus_override_value(entity)
    if bonus_override ~= nil then
        storage.crystal_bonus_overrides[key] = bonus_override
    end

    clear_crystal_destroy_registration_by_key(key)

    local registration_number = script.register_on_object_destroyed(entity)
    if registration_number then
        storage.crystal_destroy_registrations.by_key[key] = registration_number
        storage.crystal_destroy_registrations.by_registration[registration_number] = {
            key = key,
            bonus_override = bonus_override
        }
    end
end

local function take_crystal_bonus_override(entity)
    if not storage.crystal_bonus_overrides then return nil end
    local key = make_crystal_bonus_key(entity)
    if not key then return nil end
    local bonus = storage.crystal_bonus_overrides[key]
    storage.crystal_bonus_overrides[key] = nil
    return bonus
end

-- ============================================================
-- THREAT LEVEL: evolution + tech
-- ============================================================

local function get_threat_level(surface, force, opts)
    opts = opts or {}
    local tiers = opts.tech_tiers or DEFAULT_TECH_TIERS

    -- EVO
    local evo = 0
    local enemy = game.forces and game.forces["enemy"]
    if enemy then
        if enemy.get_evolution_factor then
            local ok, val = pcall(function() return enemy.get_evolution_factor(surface) end)
            if ok and type(val) == "number" then evo = val end
        elseif enemy.evolution_factor then
            local ok, val = pcall(function() return enemy.evolution_factor end)
            if ok and type(val) == "number" then evo = val end
        end
    end
    evo = math.max(0, math.min(1, evo))

    -- TECH
    local tiers_total = #tiers
    local tiers_completed = 0
    if force and force.valid then
        for _, tier_opts in ipairs(tiers) do
            local done = false
            for _, pack_name in ipairs(tier_opts) do
                local ok, rec = pcall(function() return force.recipes and force.recipes[pack_name] end)
                if ok and rec and rec.valid then
                    if rec.enabled == true then
                        done = true
                        break
                    end
                end
            end
            if done then tiers_completed = tiers_completed + 1 end
        end
    end
    local tech = (tiers_total > 0) and (tiers_completed / tiers_total) or 0
    tech = math.max(0, math.min(1, tech))

    -- combine
    local tech_weight = tonumber(opts.tech_weight) or 0.5
    tech_weight = math.max(0, math.min(1, tech_weight))

    local threat = evo * (1 - tech_weight) + tech * tech_weight
    threat = math.max(0, math.min(1, threat))

    return { evo = evo, tech = tech, threat = threat }
end

-- Пул чертежей
RUINS_BLUEPRINT_POOL = {
    { blueprint_string = "0eNqd011qhDAQB/C7zHNc1PUj8SqllKiDG6pRYiy7iNAr9aEPpdAz2Bs1urDVJUu7viVh8pt/lOkhLTtslJAakh5EVssWkoceWlFIXk5nklcICbS6VrxAR3P5DAMBIXM8QuINxFJ8QK4dPGYHLgtUi3J/eCSAUgst8Nxo3pyeZFelpjLxiLUhgaZuzaVaTl0M5MQs3IUETmbpMZftQtMkFwqzc1Ew5bqy/YvdiMbAtVOoupO5VY8Wemx0i7ff6vnXaalFD1b6n6ZnzxiSG//E+kVX2iqh51vwaI3fzLlf5HTtOeMN1I0n039SwYWijNopdncqypid8twN1hzLTIzQWJmLv7NKoOQpmpGD8W38Gj/Gz/H9+9Ucv6BqZy6MfBYwFtLA9d2ADsMPlC9BjQ==", chance = 1 },--бойлер
    { blueprint_string = "0eNqdm01u40YQhe/CtTRg/7N9lWAwkG3GI0CmDIlOMjB8gqxykwTZBMgllBuFtmFQtlmu92rnP32ubr7qqn7sfmgud/f93WE7jM3FQ7O92g/H5uKnh+a4vRk2u6efDZvbvrloxsNmON7tD+P6st+NzeOq2Q7X/W/NhXtcLfz55njsby932+Fmfbu5+r4d+rU/+5B//Lpq+mHcjtv+5R8+f/Pj23B/e9kfJurqlXQc99OHf93sds2qudsfp4/sh6f/NGHWpfuSVs2P6auYv6THp1DegTwIKhoogKCkgSII8hoogaBWA2UQ5DRQwUBZfWodCMoaqIKgqIFcC5LU5+9AbWdVAA4Udw4qCVR3VrXkQHlnVUwO1HfSnx0o8KTPE6jwpI8OlHhUc8WBGo9VXStBjUd1sfT8+h0FkqdJSSAFenRSTJEmSTHNGr/ZjP3n4woCY1b3uyL9aVGZvprq8fX20F+9/EVcYs96/3lzHNfb4dgfxuk3C+jwJtA3aOeX2B0Rd0vGXQm249ihNcUdILYzxY2xPc4+q9DYnAQTG4s7EuxCxp0Idibjzqa4MXYh2JGcEyIvz7odjF1NcUNzEltT3BibyMuzvg1jM3lJrieRyUtyPYlEXqZKsom8TKxOMlzTkidrWiTyMgUy7o7uOrywA600Seg9ElML55xrBZrDu40Z5t5PXreE9jjavUEvwQIMOysaEoxJo/bNFOqjTrjUWzXQTKtGIhW2pw+dQOrw/jlUgVEtGpYiyqaMkGLLc0YsOmqfdZwi07PMWcQiM9BMpzIjy0xFZSZLsj0/azXZcjaxK8QubO6J+qSriDiXlc5iyTZsaVIRSM6UfVJcRNFo1dCIolFVWDRUIBGGV4l5nyLC8O4q63OG2w9n64kE6/BiqAttFv/N/bAe7w+HfjHR/Ws6LtrctOEmSbWjDbcgmFsdbbgFwdzqgikZJRpdDuZGTmQmumzpo840Ux97oUthVZl8IZBIfCEQNiaVLwTCxqQ6iykaIBOjeosBCLKDxQAE2dFSzqQJThbHDwyUcc4qyS6WMixNQmexD8FAq8U+xNiubS39Q5BejTpLAyHSvMUjRAceLCYhCjdt5T/Cu0W4besSMDi9t5eWcNfym/tWQp2VqLvddhTWqjMNIA+J2e6HNzHq8+haE9xhcGcxFz/CF51Lhx4mOJOA9Nwc/aY1OAkVWTX5TkIlGlUlVLZ0tnJkxYQTo+ssK4XvMBFWExxyOZyn+z9fpKMxJifAiydtvAknRhcs68RzdMAsRhO8YPA5i3aby09Lsjz6rDFanVFMOgQHSe+NZOGYyo1PUMMRaP/AJ+kAGG0geKkDCLSD4KVeMJgsBDmyaMKJ0am5UHSGlgsJYBSN4XWGrWhgvWuwFQ2sd4180ZC6DeY1/9x2+hbrsKKthkhdVrTlhjj2OTd2++Fm/X0zXPfX2IkvOUbTpsVjzXY0vXDxWLMd6Tcu8szixvMsKod1TBH0oZ9esbxgl4/atvBK5qS28+ztvcAIOsPDq6HMCJw1L01JNLw7l4NKrJyctFvg38PLUdF7dSce1u5olNTaJVTT4XWmlg99m85puoIt5tlZ/E+Y7i0OKEwPFmsRpkfLWTmYzvjOgaZny1k8mF4sp/Fgemc5jwfTmRYus/TSWs77wXTGOEs03RvOE36EL27wSrBYfnDk9D0GcfkvtLnmpJ1oQa+jZR1V2Nt/Mqpj7//JqMreABRR6AGCuVWXUY69BSijPHsPUEahF9OqjorspUIZBao967rqMnuHT0ahl9OAuQLVnoC5AtWe9LlCjwckPQcrqPak52D17O1CGRXY64UyKrL3C2UUv3d5Rn1dNduxv50+Nl8yXz3t6/rd9LPTH6d/Tn9/O/17+vP013+/T7/5pT8cn3Ep+xprTV1sfRun7v5//03qpA==", chance = 1 },--биг_лабы
    { blueprint_string = "0eNqtk1FOwzAMhu/i52wqWdO1vQpCU9uZEalNSpJWTFUkjsQDT0hwhnIj3E2slVYhNnhLLPv7f1t2B3nZYG2kcpB2IAutLKS3HVi5U1k5xFRWIaRgdK5rbRx4BlJt8QnSG3/HAJWTTuKx6vDZb1RT5WgogX1XW6dNtsNF8YDWAYNaW6rSahAg0iISfCkY7OnJAxEvBakYfGwoe3MvS4fGDqkWi6HqKDa68J6dafMLtFf/rL06adeZtbLFRW10K7dofjART0ysycQMN7yGG024Yp4rTtyMevwdVkyw4Tw2YmfLMzv90d6fJ7++ZkLhpBU+tEJrLR1WRBmvg0GZ5UgXAf3r53P/0b/3b/0LhVtyecCJiCdhkog4DHgQxt5/ATmBH8g=", chance = 0.05 },--дронка
    { blueprint_string = "0eNqdlW1ugzAMhu/inxNULZB+cJVqqgJYayRIUJJWqxAn2SV6gEm7AkdaUtqytWFt9o+YvE9em9g0kJU7rCXjGtIGWC64gnTdgGJvnJY2xmmFkAKVTG8r1CwPc1FljFMtJLQBMF7gO6SzNnCoCsxZgdItidrXAJBrphn2p54Whw3fVRlKwwwuHFXRsgxLWtUQQC2UkQhuz7GYWTIhARwgDZfzCWmtkRtQ9CQovoISNyh+EhQ9AiXejogbRLxrNOJo/iSIPAItvB2NpLb0djQCWnkXO3aDZlPv3MZIw9129MifN8p0Gpg+1VKUmwy3dM+Mwmw7czbmXXHSKhv9uVo3tuPETtc7fV62TnNDv7jb/s/ajfkbUDcWFdq1DSpN7SAyVRY1StofAC/gdjk040X6wOP86nFqvkoABZOY9ztsyi7Tqt+gfj+bUXUde7aEpqqalechdl+a86GLdrg9WnAMa6q3YDO7vz/+kugyAp+XxP6SxF9C/CWXXIh/LsQ/F+Kfyz+MJf7GRiTmtjGNlYkOP+8ASpqh+fVC99Edu8/uqzua4B6lOpHJPFolqxVZJtNomizb9hvtkZks", chance = 1 },--лампа
    { blueprint_string = "0eNqd12tKw0AQAOC77O+kZJ/ZzVVEJNVFAskmNKlaSkBP4HVEwTOkN3LbggZk2GH+9bVfJzsz2cmRbdu9H3ZNmFh1ZM19H0ZW3RzZ2DyGuj1/FurOs4qNfVvv8qEOvmVzxprw4F9YxefbjPkwNVPjrwsvbw53Yd9t/S7+IPsFpj74/LluW5axoR/jkj6c/yAyudFmozN2iC95oeRGz3P2zxJYS6UtibV02lJYS6QtjbVk2jJYq0hbJdbiacsiLWXTlsNaLm3xAoshipVjK1+VCAxb+gpR+hxb+wpR+xxd/OtkFgC2qv4uOnlbd0OywzmArcp/de9K9SWklZQMQNdpCZsmLYA5CuaAW2yB3jSdDk1wSgpATWC1dbODmiQkFMQUBYNyoCkJLQHMUCIzAEZpAjAySyoODWiOVByAJgvKhSoA4xQMikxQikMAmKRg0ESl0Pk0iNAoRwGIkY4CUCspuwYcBZJ0FACHlHSEaRuKTGF7QJcIjBNmdxAThOEdxCRh4gYxRRi5QUwT5mQQM4RBGcRKwqAMYpYwKF+x+OzZTL6LK/+eYjPW1tvY3BU7vS3fy9fp/fS6fC4f8YsnvxsvoDbCKee0VYUolJ3nH92psSI=", chance = 0.3 },--солярки
    { blueprint_string = "0eNp9j10KwjAQhO+yz2lpY6u2VxGR1i51Id1IkvpDCQieyJvYG5kq+qL4tjvsfDszQK163BtiB+UAtNVsoVwNYKnlSk0aVx1CCXVvGE3UERO3UWNIKfACiBs8QZn6tQBkR47wBXgu5w33XY0mHIg36Kh1gxxtd2gdCNhrG0yap1cBFC1kFucCzmFMZzKNc+/FF02Kf7F+Qj/IxE9ZyWE32T/tBaiqxtAY7rfxOl6CcEBjn5B8LousKPJllsgkW3r/ACGxZwY=", chance = 1 },--бур
    { blueprint_string = "0eNqdl+FumzAQx9/Fn6ECg8HOq0xTRcBNLRnDDKytIqRpm/ZC06R+2Tskb7QjUxPS2sHmG2D7d3fc/+zzHm3lwFstVI82eyTKRnVo82mPOrFThZy+qaLmaIO45GWvRRnWQgm1CystpERjgISq+DPaxGNgWFVyBYsehh2fTcXj5wDBgOgF/2/t9PJyr4Z6yzWwgrf1rWg5ClDbdDC5URMZACFh+I4E6AUecRSxOzJO1t9R8JnS60J1baP7cMtlb+LRbMajwAtQJTREfJqUGuiJDz33pac+9NSXTnzoxJeenemyAaE8FpD1KhSq47qHcZMNfMtGjA1G8rOR8pHXoixk2MpCGUNgyQyfn/AAn5S1Qd0gH4ZJ1kUpKvQ2cP9lKCSYgwmq0XUxCf2DCzS4XRumQOnMk8wsW7Yo/iuxWihxtIwhDph4RZCJA/dSnLMtwgSL7LkbQLxiqMNWNyXvOnDKL4Fx4rfPpJZYUj8MsWDIMiZy8CZbxsQOmHxZP9QBQ5cxzAHjWRQWDHYoitwBs3w+Xe3JNgz2K1EbZlnFVxVpw6T+lX6lR/x+36YmK8RPVtjibOaXgcSCyX0OwtjBL7oWaPOQeQCv0hE5NTGRj7/UGx/74Jk3fnWH54Zf3eK54dO1XZgb3qvJS7zx2Vqlx2alJ5dafGqaiqsQGrtuQSkxY9SCu1Tizc4znaEs94iEufYqZAabepXpniN6XsPKyzUrQLKAHwXfjr8Ofw5/j9+P3w6vx5/HH4ffh1cY/sp1d8KSDLOUMXAywlFKx/EfDixWOg==", chance = 0.1 },--центрифуги
    { blueprint_string = "0eNqV0U0OgjAQBeC7zLoahFagVzHGAE7MKJSGH6MhXXgQ7+AJPAPcyAILopIYl53M+9K8aSBOa9QFqQpkA5TkqgS5aaCkg4rSfqaiDEGCrjN9jJITGAak9ngBuTJbBqgqqgjH1PC47lSdxVjYBfaVZqDz0gZy1ds94vtLweAKciECsRSW31OBybgSGPalupNKGudEPomuFWcM76chJsObN/g//1jNG+KtoR+G89mNrZ8qzGx6uiKDNIrRXg7ae/vobu2zu9nhGYtySIm1G/IwFAF3XIcHxrwAs82mig==", chance = 0.4 },--насос
    { blueprint_string = "0eNql1M1qhDAQAOBXKXOOi4m/8VVKKf4MuwGNYtzSRYT22MfpYaH00GfQN+qsS9tDs7WyN2OGbybjxB6yco9Nq3QHSQ8qr7WB5LYHo7Y6LU/vdFohJJAag1VWKr11qjTfKY2OgIGB0gU+QsKHOwaoO9UpPAvz4nCv91WGLQWwL6lRDQKDpjYUXOtTDgKcMBabgMGBHoXru5tgGNgvRSwrfFnx1incrvjsz95Y1Egu1xas6pMX25VwnSLtSvStlDWdbZfSty4cpQ22He0v9G2ujUGhWszPQVxYksTXJZH/SiLX9SOy94O7qwbHCy8wfB1zqRpx1QCeWbq1qsOKjJ8fAYMyzZAuP4zH6WU83kzP4+v4MT3R4m18p/0HbM3sBqGQvpRB7Ls00vEwfAJoUmDw", chance = 0.65 },--еще_сборщик
    { blueprint_string = "0eNqV1F1ugzAMAOC7+DmpSBoocJVqmvixaCRIUALTqorH3amadgh2o4VW6g9KR/sGwflsJzIHyOseWyNVB+kBZKGVhXR7ACsrldXTmsoahBSKHTayyGra1pkLHghIVeInpGwgnvBWtngTxIc3Aqg62Uk8Jzi97N9V3+RonELudhJotXXBWk2mA2jMo1VIYO8emeDrVThMeWcKX1bCZWVNHjTt88SNx/yeuHi1VhXdZe5MSiqVRdO57z6Vz1QCpTRYnIOEJ0d4ySGNVtQVbv31Bsv1RsunuLkqLPYrmzuFdppWRveqXPSSeb+Me/j4pat+VGTympL4FRa80qv4r1ff3bInhmP9RJVPTAefM25sZYeN23P9URCosxzdtMPv13gcf8bv8egWP9DYExZGPBFJEsYi4IGIh+EPsIZkKg==", chance = 0.2 },--химки
    { blueprint_string = "0eNptj1sKgzAQRfcy31FUjGi2UkrxMbQBnYiJbUWykm7C7sQlNbFgC+3nXO453JmhakfsB0kGxAyyVqRBHGbQ8kxl6zMqOwQBbVmBZSCpwTuI2B4ZIBlpJL6B7ZhONHYVDq7AvkEGvdKuq8gbHZ+kRcgZTCCCmEcht5b9KJJdcVOqQQrqC2rzz5XtLq+1fps02Dny8x3zQ9B9BOtjXdbnusQuu+KgNxPPkiItCp6nURKlubUvewVcbQ==", chance = 1 },--лаба1
    { blueprint_string = "0eNqV1N1qwyAUB/B3Ode25EOzmFcpoyTbYQjGlMRuK0Fo9yZ7g+1ibAy2ZzBvNNte5GIJ0StRPD/+ip4eKrnHXSuUhqIHcdeoDopND514UKU8r6myRiig043C1VMpJRgCQt3jMxSxuSWASgst8Fp3mRy2al9X2LoNZKKewK7pXEmjzr5jWLxmBA5QrDLG1swY8g9K/KBkhOg0lPpBdDERDU6UTkPMD2KLUOYHZYvQjR+UjlA0DeXBlx1PQzz4aDOJ4ihYmokUe77tfDlTEvpLKJ+R0tBHOSvR0Hu6Sq4fCI21KxsbCwFZVuiaCdjX4cV+2B/7bb+2w9G+2U/77sbf4eR2PWLbXWiWJZxyznIaJRHNjfkD3duEaw==", chance = 1 },--стенки_разброс
    { blueprint_string = "0eNqd1OFugjAQAOB3ud/FlEJReJVlMVVvrAkW0x7bjCFZ9kQ+ir7RiibqTAmMf9D2vl7v0h5gVTW4s9oQFAfQ69o4KF4O4HRpVNWNGbVFKEBZ0lWFdh9RYy0StAy02eAXFHHLAgGOaoPRp6qqh6WifWWAhjRpvG50+dkvTbNdofUWC8Qz2NXOh9Sm8z0TZXI+kwz2/lNwns1k2+XwZImxVjZsJWMtOWylY6102JKst0FDVfO6b8xGW1xfF/m8bshSNVQvSdkSSZsSCrINBvbPppwlDZ9lPsWSYWtxs7StTbR+RxesSMYfLBG28ilWErZifsPelKNIG4eW/EzonPlTbn+6FYsQH0/kk3H8/UqVinCwOT0FjZP/MX21nHSReA8mp2Bxh/knTRNufeT9MWVQqRX69xBOx/P3+ed09EMfaN2FkpnI0zyXi5QLni7a9hf4UcJK", chance = 0.025 },--арта
    { blueprint_string = "0eNqdmM+O2jAQxt/FZ2eVOHYS51UQQgGsrSUnQY4pu0Icupc99Hn6HuWN6rDaklYe7NkTwjI/zwzffP5zJltzVAerB0faM9G7cZhIuzqTST8PnZnHhq5XpCWTGweVnTpjyIUSPezVC2mLCw1NHU1ns75zVr8sJrPLmhI1OO20+ljk9uV1Mxz7rbKeRgOLUXIYJ/+TcZhX8JjmSVDyStqszJ/EZQ7gPwxLwhRljFOmcUSMw9M4PMYRaZwqxqnSOHWMUydx/obDZBjTJGHqGEYiMU0YU+Rp1clj8RQFFgRFlKjnIhrRXdDPnVMBBPsHQcleW7X7mMBDQI7sNDBFgQVBKS61rZTJdt/U5B41G0iqE0kimlyD7H8QJJGGBOXG8sTcor3LCqSXgCCGBQFFYiXSJUEQj3VLg+sWlihyGa1VmoGzqEWxGguCarWQeO8ZmTK+ElbvssNo1KM9oQaAEmueFbCH51jzhEBoOwdSK1m6C1cpuipLrHlCKaLtHErxrvTTvt8ctPWJbkw3KZu5o7Uq5DXsU2JBIt7XodhqrIlCoAYLgsousfsDAOJ4Wwdy42hbh0BoW4dyQ9s6BELYelL78a+IXT4SO6+wGwWUK9rfIVCDBUF6wJ7SOXAVynFXRZCDvHIyAXAYbgNceDxELLEigFLkyNBkNDSB/BNLgFNhe5oBILTOIdBC58s3jMB54RMUxKAP6gVwU8+xFbqB1pScvGnNbywrfzQT1MtTrOlq/qBeD2LtZ2ines+9P/9QYrqtMn7s+v771/XH9e360w9+V3a6LSUqJrmUouE5y7l3rj+IEc9T", chance = 0.1 },--честы
}
if DEFAULT_EVENTS and DEFAULT_EVENTS.ruins then
    DEFAULT_EVENTS.ruins.blueprint_pool = RUINS_BLUEPRINT_POOL
end

local function get_ruins_blueprint_pool()
    return storage and storage.ruins_blueprint_pool or RUINS_BLUEPRINT_POOL
end
local function normalize_ruins_blueprint_pool_entries(pool)
    if not pool then return {} end
    local entries = {}
    for _, item in ipairs(pool) do
        if type(item) == "string" and item ~= "" then
            entries[#entries + 1] = { blueprint_string = item, weight = 1 }
        elseif type(item) == "table" then
            local bp = item.blueprint_string or item.blueprint or item[1]
            if type(bp) == "string" and bp ~= "" then
                local w = tonumber(item.weight) or tonumber(item.chance) or tonumber(item.probability) or 1
                w = (type(w) == "number") and w or 1
                if w > 0 then
                    entries[#entries + 1] = { blueprint_string = bp, weight = w }
                end
            end
        end
    end
    return entries
end

-- Выбор чертежа из пула с учетом весов (weight/chance). Строковые записи равны weight=1.
local function pick_ruins_blueprint_from_pool(pool)
    local entries = normalize_ruins_blueprint_pool_entries(pool)
    if not entries or #entries == 0 then return nil end

    local total = 0
    for _, e in ipairs(entries) do total = total + (e.weight or 0) end
    if total <= 0 then
        return entries[math.random(#entries)].blueprint_string
    end

    local r = math.random() * total
    local acc = 0
    for _, e in ipairs(entries) do
        acc = acc + (e.weight or 0)
        if r <= acc then
            return e.blueprint_string
        end
    end

    return entries[#entries].blueprint_string
end

-- Заполнение лута в контейнерах руин в зависимости от уровня угрозы
local RUINS_LOOT_POOL = {
    {name = "iron-ore", min = 1, max = 100, chance = 0.1},
    {name = "copper-ore", min = 1, max = 100, chance = 0.1},
    {name = "coal", min = 1, max = 100, chance = 0.1},
    {name = "stone", min = 1, max = 100, chance = 0.1},

    {name = "steel-plate", min = 1, max = 25, chance = 0.2, min_threat = 0.1},
    {name = "firearm-magazine", min = 5, max = 15, chance = 0.2},

    {name = "electronic-circuit", min = 1, max = 20, chance = 0.35, min_threat = 0.3},
    {name = "uranium-ore", min = 1, max = 15, chance = 0.35, min_threat = 0.3},
    {name = "wdm-ore-warponium", min = 1, max = 40, chance = 0.35, min_threat = 0.3},

    {name = "advanced-circuit", min = 2, max = 10, chance = 0.3, min_threat = 0.7},
    {name = "processing-unit", min = 1, max = 10, chance = 0.1, min_threat = 0.7},

    {name = "spidertron", min = 1, max = 1, chance = 0.025, min_threat = 0.8},
    {name = "green-refined-concrete", min = 10, max = 50, chance = 0.025, min_threat = 0.7}
}

local function fill_ruins_loot(entities, current_threat)
    if not entities or #entities == 0 then return end
    current_threat = current_threat or 0

    for _, e in pairs(entities) do
        if e.valid and (e.type == "container" or e.type == "logistic-container") then
            for _, item in ipairs(RUINS_LOOT_POOL) do
                -- Проверка: порог угрозы пройден ИЛИ порог не задан
                local threat_ok = not item.min_threat or (current_threat >= item.min_threat)
                
                if threat_ok and math.random() <= item.chance then
                    local count = math.random(item.min, item.max)
                    e.insert({name = item.name, count = count})
                    if is_debug_enabled() then
                        debug("Inserted loot '" .. tostring(item.name) .. "' x" .. tostring(count) .. " (min_threat=" .. tostring(item.min_threat) .. ") for current_threat=" .. string.format("%.3f", current_threat))
                    end
                end
            end
        end
    end
end

local function in_list(list, val)
    for _, v in ipairs(list) do
        if v == val then return true end
    end
    return false
end

local function pirate_load_turrets(entities)
    if not entities or #entities == 0 then return end
    
    local gun_ammo = "piercing-rounds-magazine"
    if prototypes.item["armor-piercing-rifle-magazine"] then gun_ammo = "armor-piercing-rifle-magazine" end
    
    for _, e in pairs(entities) do
        if e.valid then
            if e.name == 'gun-turret' then 
                e.insert({name = gun_ammo, count = 20}) 
            elseif e.name == 'wdm_pirate_rocket-turret' then 
                e.insert({name = "rocket", count = 10}) 	
            elseif e.name == 'wdm_pirate_railgun-turret' then 
                e.insert({name = "railgun-ammo", count = 5}) 
            end
        end
    end
end

-- Создание стака чертежа
local function make_ruins_blueprint_stack(blueprint_string)
    if not (game and type(blueprint_string) == "string" and blueprint_string ~= "") then return nil end

    local ok_inv, inv = pcall(function()
        return game.create_inventory(1)
    end)
    if not (ok_inv and inv and inv.valid) then return nil end

    local stack = inv[1]
    if not (stack and stack.valid) then return nil end

    stack.set_stack({ name = "blueprint", count = 1 })
    
    local import_result = nil
    pcall(function()
        import_result = stack.import_stack(blueprint_string)
    end)
    
    if import_result == 1 or not (stack.valid_for_read and stack.is_blueprint_setup()) then 
        inv.destroy()
        return nil 
    end

    return stack, inv
end

local function get_blueprint_bounding_box(stack)
    if not (stack and stack.valid_for_read and stack.is_blueprint_setup()) then return nil end

    local entities = stack.get_blueprint_entities()
    if not entities or #entities == 0 then return nil end

    local min_x, min_y = math.huge, math.huge
    local max_x, max_y = -math.huge, -math.huge

    for _, e in ipairs(entities) do
        local proto = prototypes.entity[e.name]
        local box = proto and proto.collision_box or {left_top={x=-0.5, y=-0.5}, right_bottom={x=0.5, y=0.5}}
        
        local left = e.position.x + box.left_top.x
        local top = e.position.y + box.left_top.y
        local right = e.position.x + box.right_bottom.x
        local bottom = e.position.y + box.right_bottom.y

        if left < min_x then min_x = left end
        if top < min_y then min_y = top end
        if right > max_x then max_x = right end
        if bottom > max_y then max_y = bottom end
    end

    return {
        left_top = {x = min_x, y = min_y},
        right_bottom = {x = max_x, y = max_y}
    }
end

local function is_area_clear_of_water(surface, box, center_pos)
    local offset_x = math.abs(box.right_bottom.x - box.left_top.x) * 0.25
    local offset_y = math.abs(box.right_bottom.y - box.left_top.y) * 0.25

    local points = {
        {x = center_pos.x, y = center_pos.y},
        {x = center_pos.x - offset_x, y = center_pos.y - offset_y},
        {x = center_pos.x + offset_x, y = center_pos.y + offset_y}
    }

    for i = 1, #points do
        local p = points[i]
        local tile = surface.get_tile(p.x, p.y)
        if tile and tile.valid then
            local tile_proto = tile.prototype
            local mask = tile_proto and tile_proto.collision_mask
            if mask and mask.layers then
                if mask.layers["water"] then
                    return false
                end
            end
        end
    end

    return true
end

local function find_clear_space_for_blueprint(surface, bp_box, start_center, max_radius)
    local start_x = math.floor(start_center.x) + 0.5
    local start_y = math.floor(start_center.y) + 0.5

    if is_area_clear_of_water(surface, bp_box, {x = start_x, y = start_y}) then
        return {x = start_x, y = start_y}
    end

    local step = 8
    local x = 0
    local y = 0
    local dx = 0
    local dy = -1

    local max_steps = math.ceil(max_radius / step)
    local total_iterations = (max_steps * 2 + 1) * (max_steps * 2 + 1)

    for i = 1, total_iterations do
        if (x == y) or (x < 0 and x == -y) or (x > 0 and x == 1 - y) then
            local temp = dx
            dx = -dy
            dy = temp
        end

        x = x + dx
        y = y + dy

        local candidate_pos = {
            x = start_x + (x * step),
            y = start_y + (y * step)
        }

        local dist_x = math.abs(x * step)
        local dist_y = math.abs(y * step)
        local max_dist = dist_x > dist_y and dist_x or dist_y

        if max_dist <= max_radius then
            if is_area_clear_of_water(surface, bp_box, candidate_pos) then
                return candidate_pos
            end
        end
    end

    return start_center
end

local function spawn_ruins_blueprint(surface, area, blueprint_string, opts)
    if not (surface and surface.valid and area and blueprint_string) then return false end

    opts = opts or {}
    local stack, inv = make_ruins_blueprint_stack(blueprint_string)
    if not stack then return false end
    
    local threat_force = nil
    if opts.force then
        threat_force = opts.force
    elseif opts.ship and opts.ship.force then
        if type(opts.ship.force) == "table" then
            threat_force = opts.ship.force
        elseif type(opts.ship.force) == "string" and game and game.forces then
            threat_force = game.forces[opts.ship.force]
        end
    end
    if not (threat_force and threat_force.valid) then
        threat_force = game and game.forces and (game.forces.player or game.forces["player"]) or nil
    end
    
    local threat_data = get_threat_level(surface, threat_force, {
        tech_weight = tonumber(opts.tech_influence) or 1,
        tech_tiers = opts.tech_tiers
    })
    local current_threat = threat_data.threat or 0

    local build_force = (game and game.forces and (game.forces.neutral or game.forces["neutral"]))
        or threat_force
        or (game and game.forces and (game.forces.player or game.forces["player"]))

    local center = {
        x = ((area.left_top.x or 0) + (area.right_bottom.x or 32)) / 2,
        y = ((area.left_top.y or 0) + (area.right_bottom.y or 32)) / 2
    }
    
    local candidate = center
    local bp_box = get_blueprint_bounding_box(stack)
    
    if bp_box then
        local bp_w = math.abs(bp_box.right_bottom.x - bp_box.left_top.x)
        local bp_h = math.abs(bp_box.right_bottom.y - bp_box.left_top.y)
        local max_side = bp_w > bp_h and bp_w or bp_h
        local search_radius = math.max(32, math.ceil(max_side / 2) + 48)
--        surface.request_to_generate_chunks(center, math.ceil(search_radius / 32))
        candidate = find_clear_space_for_blueprint(surface, bp_box, center, search_radius)
    end

    -- Размещение призраков чертежа на карте
    local ok, built = pcall(function()
        return stack.build_blueprint{
            surface = surface,
            force = build_force,
            position = candidate,
            force_build = true,
            build_mode = defines.build_mode.super_forced, 
            skip_fog_of_war = false,
            raise_built = false
        }
    end)

    local built_count = 0
    if ok and type(built) == "table" then
        local revived_entities = {}
        for _, ghost in pairs(built) do
            if ghost and ghost.valid then
                local _, revived = ghost.revive({ raise_built = false })
                if revived and revived.valid then
                    if revived.name == "gun-turret" or revived.name == "wdm_pirate_railgun-turret" or revived.name == "wdm_pirate_laser-turret" then
                        if game and game.forces and game.forces.enemy then
                            revived.force = game.forces.enemy
                        end
                    end
                    revived_entities[#revived_entities + 1] = revived
                    built_count = built_count + 1
                end
            end
        end
        if built_count > 0 then
            pirate_load_turrets(revived_entities)
            fill_ruins_loot(revived_entities, current_threat)

            local force_name = (threat_force and threat_force.name) or "neutral"
            debug("Ruins spawned for " .. force_name .. ". Loot Threat: " .. string.format("%.2f", current_threat))
        end
    end

    if inv and inv.valid then
        pcall(function() inv.destroy() end)
    end

    return ok and built_count > 0
end

local function consume_crystal_destroy_registration_by_key(key)
    if not (storage and storage.crystal_destroy_registrations and key) then return nil end
    local registrations = storage.crystal_destroy_registrations
    local registration_number = registrations.by_key[key]
    if not registration_number then return nil end

    registrations.by_key[key] = nil
    local record = registrations.by_registration[registration_number]
    registrations.by_registration[registration_number] = nil
    return record
end

local function consume_crystal_destroy_registration_for_entity(entity)
    local key = make_crystal_bonus_key(entity)
    if not key then return nil end
    return consume_crystal_destroy_registration_by_key(key)
end

-- ============================================================
-- Дружественный урон (FRIENDLY FIRE) ДЛЯ СИЛ
-- ============================================================

local FRIENDLY_FIRE_FORCES = { "enemy", "pirate" }

local function apply_friendly_fire_setting()
    if not game or not game.forces then return end

    local disable = is_friendly_fire_disabled()

    for _, name in ipairs(FRIENDLY_FIRE_FORCES) do
        local force = game.forces[name]
        if force and force.valid and force.friendly_fire ~= nil then
            -- Если настройка включена - отключаем дружественный урон,
            -- иначе возвращаем дефолтное поведение (разрешаем).
            force.friendly_fire = not disable
        end
    end
end

-- WAP теперь управляется WDM, не нужны локальные функции

local function sync_default_events()
    storage.events = storage.events or {}
    for name, params in pairs(DEFAULT_EVENTS) do
            storage.events[name] = util.table.deepcopy(params)
            debug("Added new default event: " .. name)
    end
    for name, _ in pairs(storage.events) do
        if not DEFAULT_EVENTS[name] then
            debug("Removed obsolete event: " .. name)
            storage.events[name] = nil
        end
    end
end

-- Регистрация событий в WDM через add_custom_planet_event
local function register_wdm_planet_events()
    if not remote.interfaces["WDM"] then
        debug("WDM interface not found, cannot register planet events")
        return false
    end

    local merged_events = {}
    for event_name, default_cfg in pairs(DEFAULT_EVENTS) do
        merged_events[event_name] = (storage.events and storage.events[event_name]) or default_cfg
    end
    for event_name, stored_cfg in pairs(storage.events or {}) do
        if not merged_events[event_name] then
            merged_events[event_name] = stored_cfg
        end
    end

    local ok, err = pcall(function()
        for event_name, event_config in pairs(merged_events) do
            if event_config.wdm_chance then
                remote.call("WDM", "add_custom_planet_event",
                    event_name,                    -- name
                    event_config.wdm_chance,       -- chance
                    event_config.wdm_min_wap,      -- min_wap
                    event_config.wdm_min_tech_progress,  -- min_tech_progress
                    event_config.wdm_can_be_removed or false,  -- can_be_removed
                    event_config.wdm_difficulty_add or 0.0,    -- difficulty_add
                    event_config.wdm_no_repeat or false,       -- no_repeat
                    event_config.wdm_requires_enemies or false, -- requires_enemies
                    event_config.wdm_must_have_on or nil,       -- must_have_on
                    event_config.wdm_alarm or false -- alarm
                )
                debug("Registered WDM planet event: " .. event_name)
            end
        end
    end)
    
    if not ok then
        debug("Error registering WDM planet events: " .. tostring(err))
        return false
    end
    
    return true
end

-- Возвращает уровень технологии размера палубы (0..8) для силы
local function get_ship_floor_size_tech_level(force)
    if not (force and force.valid and force.technologies) then return 0 end
    for lvl = 8, 1, -1 do
        local tech_name = "wdm_ship_floor_1_size_tech-" .. tostring(lvl)
        local tech = force.technologies[tech_name]
        if tech and tech.researched then
            return lvl
        end
    end
    return 0
end

-- EXTRA RADIUS BY TECH
-- Определяет номер группы уровня (floor_number) для поверхности:
--   поверхность (не ship_interior)          → floor 1
--   ship_interior_<N>_<force_name> для N=1  → floor 2
--   ship_interior_<N>_<force_name> для N=2  → floor 3
--   ship_interior_<N>_<force_name> для N=3  → floor 4
--   ship_interior_<N>_<force_name> для N>=4 → floor N+1
--   ship_interior_h_<force_name>            → floor 1
local function get_surface_floor_number(surface)
    if not (surface and surface.valid and surface.name) then return 1 end
    local name = surface.name
    local prefix = "ship_interior_"
    -- Если имя не начинается с ship_interior_ - это поверхность планеты
    if string.sub(name, 1, #prefix) ~= prefix then
        return 1
    end
    -- Извлекаем deck_id: ship_interior_<deck_id>_<force_name>
    local rest = string.sub(name, #prefix + 1)
    local underscore_pos = string.find(rest, "_")
    if not underscore_pos then return 1 end
    local deck_id = string.sub(rest, 1, underscore_pos - 1)
    -- "h"приравниваем к floor 1
    if deck_id == "h" then return 1 end
    local id = tonumber(deck_id)
    if not id then return 1 end
    return id + 1
end

-- Первое значение - базовый радиус (0-й уровень технологии),
-- последующие - для уровней технологии 1, 2, ... до max_level.
-- tech_prefix - префикс технологии размера палубы для определения уровня.
local GAS_LEAK_RADIUS_BY_FLOOR = {
    [1] = {
        values = {13, 25, 35, 44, 52, 59, 65, 70, 74},
        max_level = 8,
        tech_prefix = "wdm_ship_floor_1_size_tech-"
    },
    [2] = {
        values = {8, 16, 24, 32, 40, 48, 56, 64},
        max_level = 7,
        tech_prefix = "wdm_ship_floor_2_size_tech-"
    },
    [3] = {
        values = {8, 16, 24, 30, 36, 40, 43},
        max_level = 6,
        tech_prefix = "wdm_ship_floor_3_size_tech-"
    },
    [4] = {
        values = {11, 23, 35, 45, 55, 64},
        max_level = 5,
        tech_prefix = "wdm_ship_floor_4_size_tech-"
    },
}

local function get_gas_leak_radius_by_tech(force, surface)
    local floor_num = get_surface_floor_number(surface)
    local data = GAS_LEAK_RADIUS_BY_FLOOR[floor_num]
    -- Автоматический расчет для floor >= 5 (ship_interior_4+)
    if not data then
        local max_level = 9 - floor_num        -- уровней становится меньше с ростом floor
        if max_level < 1 then max_level = 1 end
        local base_radius = 14 + (floor_num - 5) * 3  -- базовый радиус увеличивается
        local increment = 8 + (floor_num - 5)          -- прирост за уровень
        local values = {}
        for i = 0, max_level do
            values[i + 1] = base_radius + increment * i
        end
        data = { values = values, max_level = max_level, tech_prefix = nil }
    end

    local lvl = 0
    if data.tech_prefix and force and force.valid and force.technologies then
        for l = data.max_level, 1, -1 do
            local tech = force.technologies[data.tech_prefix .. tostring(l)]
            if tech and tech.researched then
                lvl = l
                break
            end
        end
    end

    local max_radius = data.values[lvl + 1] or data.values[1] or 12
    -- initial_radius = 25% от max_radius
    local initial_radius = math.max(2, math.floor(max_radius * 0.25))

    return max_radius, initial_radius
end

-- Вычисляет min/max дистанции спавна по уровню технологии и опциональному модификатору
local function compute_spawn_distance_range_by_tech(force, opts)
    opts = opts or {}
    local base_by_level = {80, 92, 102, 111, 119, 126, 132, 137, 141}
    local lvl = get_ship_floor_size_tech_level(force) or 0
    local base_min = base_by_level[lvl + 1] or 80
    local modifier = tonumber(opts.spawn_distance_modifier) or tonumber(opts.distance_modifier) or 1
    if modifier <= 0 then modifier = 1 end
    local min_dist = math.floor(base_min * modifier)
    local max_dist = math.floor(min_dist * 3)
    return min_dist, max_dist
end

-- ============================================================
-- ПОИСК ПОЗИЦИЙ
-- ============================================================

local function find_spawn_position_near_ship(ship, surface, min_dist, max_dist, prototype)
    if not (ship and ship.position) then return { x = 0, y = 0 } end
    if not (surface and surface.valid) then return ship.position end

    local base_pos = ship.position
    local station_pos = ship.active_space_station and ship.active_space_station.position
    local attempts = 0
    local pos, valid
    while not valid and attempts < 60 do
        attempts = attempts + 1
        local angle = math.random() * math.pi * 2
        local dist = math.random(min_dist, max_dist)
        local x = base_pos.x + math.cos(angle) * dist
        local y = base_pos.y + math.sin(angle) * dist
        pos = { x = x, y = y }

        if prototype and surface.find_non_colliding_position then
            local safe = surface.find_non_colliding_position(prototype, pos, 16, 0.5, false)
            if safe then pos = safe end
        end

        valid = ((not station_pos) or distance(pos, station_pos) > 90) and is_non_water_tile(surface, pos)
    end

    if valid then return pos end

    if prototype and surface.find_non_colliding_position then
        local fallback = surface.find_non_colliding_position(prototype, base_pos, 64, 0.5, false)
        if fallback and is_non_water_tile(surface, fallback) then
            return fallback
        end
    end

    if is_non_water_tile(surface, base_pos) then
        return base_pos
    end

    return nil
end

-- Helper: Send unit to a specific location (adapted for WDM conditions)
local function unit_go_to_location(unit, destination, surface, distraction, stay)
    if not (unit and unit.valid and destination) then return end
    
    distraction = distraction or defines.distraction.by_enemy
    local cmd_unit = unit
    
    -- Get commandable interface if available
    if unit.object_name == "LuaEntity" and unit.commandable then
        cmd_unit = unit.commandable
    end
    
    if not cmd_unit then return end
    
    local command = {
        type = defines.command.go_to_location,
        destination = destination,
        pathfind_flags = {
            use_cache = true,
            low_priority = false,
            allow_destroy_friendly_entities = false
        },
        distraction = distraction
    }
    
    if stay then
        -- Add loitering when arriving at destination
        command.radius = 15
    end
    
    pcall(function()
        cmd_unit.set_command(command)
    end)
end

local function find_boss_edge_spawn_position(surface, ship, force, edge_distance)
    if not (surface and surface.valid) then return nil end
    if not (ship and ship.position) then return nil end
    
    edge_distance = edge_distance or 150
    local ship_pos = ship.position
    local station_pos = ship.active_space_station and ship.active_space_station.position
    local min_station_distance = 90
    
    -- Метод 1: Ищем НАСТОЯЩУЮ границу исследованных чанков
    local num_rays = 24
    local edge_candidates = {}
    
    for ray_idx = 0, num_rays - 1 do
        local angle = (ray_idx / num_rays) * 2 * math.pi
        local dir_x = math.cos(angle)
        local dir_y = math.sin(angle)
        
        -- Увеличиваем макс. радиус до 40 чанков (~1280 тайлов) на случай огромных баз
        local max_step = 40 
        local edge_step = nil
        
        for step = 1, max_step do
            -- Шагаем строго по чанкам наружу от корабля
            local test_x = ship_pos.x + dir_x * step * 32
            local test_y = ship_pos.y + dir_y * step * 32
            
            local chunk_x = math.floor(test_x / 32)
            local chunk_y = math.floor(test_y / 32)
            
            local ok, is_generated = pcall(function()
                -- В Factorio API передается таблица координат чанка
                return surface.is_chunk_generated({chunk_x, chunk_y})
            end)
            
            -- Нам нужен ПЕРВЫЙ чанк, который НЕ сгенерирован (это начало тумана войны)
            if ok and not is_generated then
                -- Чтобы босс не спавнился слишком близко к кораблю (минимум 3 чанка / 96 тайлов)
                if step >= 3 then
                    edge_step = step
                end
                break
            end
            
            if not ok then break end
        end
        
        if edge_step then
            local edge_pos = {
                x = ship_pos.x + dir_x * (edge_step - 1) * 32,
                y = ship_pos.y + dir_y * (edge_step - 1) * 32,
                ray = ray_idx
            }
            table.insert(edge_candidates, edge_pos)
        end
    end
    
    -- Если нашли реальные края карты
    if #edge_candidates > 0 then
        -- Для разнообразия выбираем случайный сектор края
        local chosen_edge = edge_candidates[math.random(#edge_candidates)]
        
        local attempts = 0
        while attempts < 40 do
            attempts = attempts + 1
            
            -- Изменено: закидываем босса НАУРУЖУ (вглубь тумана), а не возвращаем к кораблю!
            local offset_into_fog = math.random(20, 50) 
            local spread_angle = math.random() * math.pi / 6 - math.pi / 12  -- ±15 градусов
            
            local angle_from_edge = (chosen_edge.ray / num_rays) * 2 * math.pi + spread_angle
            
            local candidate = {
                x = chosen_edge.x + math.cos(angle_from_edge) * offset_into_fog,
                y = chosen_edge.y + math.sin(angle_from_edge) * offset_into_fog
            }
            
            local valid = true
            if not is_non_water_tile(surface, candidate) then valid = false end
            
            if valid and station_pos then
                local dist = math.sqrt((candidate.x - station_pos.x)^2 + (candidate.y - station_pos.y)^2)
                if dist < min_station_distance then valid = false end
            end
            
            if valid then
                debug("has_boss_2: Successfully found edge spawn at ray " .. tostring(chosen_edge.ray))
                return candidate
            end
        end
    end
    
    -- Метод 2: НАДЁЖНЫЙ FALLBACK (если база гигантская или края не подошли)
    -- Спавним строго НА УДАЛЕНИИ от корабля, чтобы не сломать базу
    local fallback_attempts = 0
    while fallback_attempts < 30 do
        fallback_attempts = fallback_attempts + 1
        local angle = math.random() * 2 * math.pi
        -- Если у игрока огромная база, спавним босса дальше (минимум 250 тайлов)
        local distance = math.max(edge_distance, 250) + math.random(-30, 30)
        
        local candidate = {
            x = ship_pos.x + math.cos(angle) * distance,
            y = ship_pos.y + math.sin(angle) * distance
        }
        
        local valid = true
        if not is_non_water_tile(surface, candidate) then valid = false end
        
        if valid and station_pos then
            local dist_from_station = math.sqrt((candidate.x - station_pos.x)^2 + (candidate.y - station_pos.y)^2)
            if dist_from_station < min_station_distance then valid = false end
        end
        
        if valid then
            debug("has_boss_2: Fallback spawn used at safe distance: " .. string.format("%.1f", distance))
            return candidate
        end
    end
    
    return nil
end

local function spawn_laser_boss_far_entity(ship, surface, prototype, count, opts)
    if not (surface and surface.valid) then return end
    prototype = prototype or "kj_electric_laser_t1"
    count = (count and count > 0) and count or 1
    opts = opts or {}

    -- determine force for tech lookups (derive from ship)
    local force = nil
    if ship and ship.force and type(ship.force) == "table" then
        force = ship.force
    elseif ship and ship.force and type(ship.force) == "string" then
        force = game.forces[ship.force]
    end
    if not (force and force.valid) then force = game.forces["player"] end

    local base_pos = (ship and ship.position) or { x = 0, y = 0 }

    for i = 1, count do
        local spawn_prototype = prototype
        local elite_chance = HAS_SPACE_AGE and (opts.elite_chance or 0) or 0
        local elite_prototype = prototype .. "_tesla"
        if elite_chance > 0 and math.random() < elite_chance and prototypes.entity[elite_prototype] then
            spawn_prototype = elite_prototype
        end

        local radial_offset = (i - 1) * (opts.spacing or 60)
        local min_dist, max_dist
        if opts.min_dist or opts.max_dist then
            min_dist = opts.min_dist or 100
            max_dist = opts.max_dist or (min_dist * 2)
        else
            min_dist, max_dist = compute_spawn_distance_range_by_tech(force, opts)
        end
        local pos = find_spawn_position_near_ship(ship, surface, min_dist + radial_offset, max_dist + radial_offset, spawn_prototype)
        if not pos then
            debug("Failed to find non-water spawn position for prototype=" .. tostring(spawn_prototype))
            pos = base_pos
        end

        if surface.find_non_colliding_position then
            local safe = surface.find_non_colliding_position(spawn_prototype, pos, 8, 0.5, false)
            if safe and is_non_water_tile(surface, safe) then pos = safe end
        end

        if not is_non_water_tile(surface, pos) then
            debug("Skipped laser boss spawn on invalid tile for prototype=" .. tostring(spawn_prototype))
            goto continue
        end

        local ok, boss = pcall(function()
            return surface.create_entity{
                name = spawn_prototype,
                position = pos,
                force = game.forces.enemy,
                create_build_effect_smoke = false
            }
        end)

        if ok and boss and boss.valid then
            if boss.energy ~= nil then boss.energy = boss.electric_buffer_size or 0 end
            apply_turret_delay(boss, 15)
            pcall(function()
                surface.create_entity{
                    name = "solar-panel-explosion",
                    position = boss.position
                }
                surface.create_entity{
                    name = "solar-panel-explosion",
                    position = boss.position
                }
            end)
            -- localized print with gps ping
            game.print({ "wdm-expansion.laser_boss_spawned", boss.gps_tag })
        else
            debug("Failed to create boss entity at (" .. tostring(pos.x) .. "," .. tostring(pos.y) .. ") (ok=" .. tostring(ok) .. ") prototype=" .. tostring(spawn_prototype))
        end

        ::continue::
    end
end


-- ============================================================
-- ACTIONS (действия событий) - объявляем заранее
-- ============================================================

local ACTIONS = {}

-- forward declaration so ACTIONS can call teleport helper
local sync_chunk_generated_handler
local teleport_player_to_available_deck
local find_safe_teleport_position
local spawn_crystals
local ensure_crystal_tick
local collect_ship_floor_surfaces_for_force
local open_gas_leak_repair_gui

-- ============================================================
-- СИСТЕМА ПЛАНИРОВАНИЯ
-- ============================================================

-- Объявляем функцию заранее, определение будет ниже
local update_tick_handlers

local function schedule_event_for_tick(name, ship, surface, delay, meta)
    storage.scheduled_events = storage.scheduled_events or {}
    local ship_info = {
        pos = ship and ship.position,
        force_name = ship and ship.force and ship.force.name,
        station_pos = ship and ship.active_space_station and ship.active_space_station.position
    }
    table.insert(storage.scheduled_events, {
        tick = game.tick + (delay or 2),
        name = name,
        surface_index = surface and surface.index,
        ship_info = ship_info,
        meta = meta
    })
    -- Включаем on_tick когда добавляем событие
    if update_tick_handlers then
        update_tick_handlers()
    end
end

-- Обработка события когда планета сгенерирована с нашим событием
-- Вызывается через on_custom_planet_event из WDM
local function handle_custom_planet_event(event_name, ship, surface)
    local ev = storage.events and storage.events[event_name] or DEFAULT_EVENTS[event_name]
    if not ev then
        debug("Unknown event name: " .. tostring(event_name))
        return
    end

    cleanup_triggered_surface_events()

    if not should_trigger_surface_event(surface, ship, event_name, ev) then
        debug("Skipping custom planet event after revisit roll: " .. tostring(event_name) .. " on surface " .. tostring(surface and surface.name))
        return
    end

    debug("Handling custom planet event: " .. event_name .. " on surface " .. tostring(surface and surface.name))

    -- Создаем ship_stub для совместимости с ACTIONS
    local ship_stub = {
        position = ship.position,
        force = ship.force,
        active_space_station = ship.planet_info and ship.planet_info.station_pos and { position = ship.planet_info.station_pos } or nil
    }

    local action_name = ev.action_name
    if not action_name then
        debug("No action_name for event: " .. event_name)
        return
    end

    local action = ACTIONS[action_name]
    if not action then
        debug("No action found: " .. action_name)
        return
    end

    -- Для laser_boss добавляем задержку и волны
    local meta = nil
    if event_name == "laser_boss" then
        local seconds = math.random(60, 120)
        local delay_ticks = seconds * 60
        
        -- Broadcast detected message
        game.print({ "wdm-expansion.laser_boss_detected" })
        debug("laser_boss will be scheduled after " .. tostring(seconds) .. " seconds (" .. tostring(delay_ticks) .. " ticks)")

        local wmin = (ev.waves and ev.waves.min) or 1
        local wmax = (ev.waves and ev.waves.max) or 1
        if wmin < 1 then wmin = 1 end
        if wmax < wmin then wmax = wmin end
        local waves = math.random(wmin, wmax)

        meta = {
            waves_remaining = waves,
            total_waves = waves,
            wave_min_delay_seconds = ev.wave_min_delay_seconds or 20,
            wave_max_delay_seconds = ev.wave_max_delay_seconds or 60,
            tech_influence = ev.tech_influence,
            tech_tiers = ev.tech_tiers
        }

        -- Запланировать первую волну с задержкой
        mark_surface_event_triggered(surface, ship, event_name)
        schedule_event_for_tick(event_name, ship_stub, surface, delay_ticks, meta)
        return
    end

    -- Для has_boss_2 добавляем задержку
    if event_name == "has_boss_2" then
        local min_seconds = ev.wdm_min_delay or 30
        local max_seconds = ev.wdm_max_delay or 120
        local seconds = math.random(min_seconds, max_seconds)
        local delay_ticks = seconds * 60
        
        -- Show detected message at half time before spawn
        local message_delay_ticks = math.floor(delay_ticks / 2)
        debug("has_boss_2 will be scheduled after " .. tostring(seconds) .. " seconds (" .. tostring(delay_ticks) .. " ticks), message at " .. tostring(message_delay_ticks) .. " ticks")

        meta = {
            tech_influence = ev.tech_influence,
            tech_tiers = ev.tech_tiers,
            detected_message_tick = game.tick + message_delay_ticks
        }

        mark_surface_event_triggered(surface, ship, event_name)
        schedule_event_for_tick(event_name, ship_stub, surface, delay_ticks, meta)
        return
    end

    -- Для других событий (earthquake) выполняем сразу
    local ok, err = pcall(action, surface, ev, ship_stub, meta)
    if not ok then
        debug("Error executing action for event '" .. event_name .. "': " .. tostring(err))
        return
    end

    mark_surface_event_triggered(surface, ship, event_name)
end

-- ACTION: Спавн лазерного босса (использует unified threat level)
ACTIONS.spawn_laser_boss_far = function(surface, ev, ship_stub, meta)
    local base_count = ev.spawn_count or ev.count or 1
    local opts = ev.spawn_opts or {}
    -- allow DEFAULT_EVENTS to carry a spawn distance modifier at top-level
    if not opts.spawn_distance_modifier then
        opts.spawn_distance_modifier = ev.spawn_distance_modifier or ev.spawn_distance_multiplier or opts.spawn_distance_modifier
    end

    -- force for tech lookups
    local force = nil
    if ship_stub and ship_stub.force and type(ship_stub.force) == "table" then
        force = ship_stub.force
    elseif ship_stub and ship_stub.force and type(ship_stub.force) == "string" then
        force = game.forces[ship_stub.force]
    end
    if not (force and force.valid) then force = game.forces["player"] end

    local t = get_threat_level(surface, force, { tech_weight = ev.tech_influence or (meta and meta.tech_influence) or 0.5, tech_tiers = ev.tech_tiers or (meta and meta.tech_tiers) })
    local tier = math.floor(t.threat * 9) + 1
    tier = math.max(1, math.min(10, tier))
    local prototype_name = "kj_electric_laser_t" .. tostring(tier)
    opts.elite_chance = HAS_SPACE_AGE and (opts.elite_chance or 0) or 0

    -- wave index and dynamic spawn_count
    local wave_index = 1
    if meta and meta.total_waves and meta.waves_remaining then
        wave_index = (meta.total_waves - meta.waves_remaining) + 1
        if wave_index < 1 then wave_index = 1 end
    end
    local spawn_count_dynamic = base_count + (wave_index - 1)

    -- spawn entities
    spawn_laser_boss_far_entity(ship_stub, surface, prototype_name, spawn_count_dynamic, opts)

    -- schedule next wave if needed
    if meta and type(meta) == "table" and meta.waves_remaining and meta.waves_remaining > 1 then
        local next_waves_remaining = meta.waves_remaining - 1
        local min_s = meta.wave_min_delay_seconds or 20
        local max_s = meta.wave_max_delay_seconds or 60
        if min_s < 1 then min_s = 1 end
        if max_s < min_s then max_s = min_s end
        local seconds = math.random(min_s, max_s)
        local delay_ticks = seconds * 60

        local next_meta = {
            waves_remaining = next_waves_remaining,
            total_waves = meta.total_waves,
            wave_min_delay_seconds = meta.wave_min_delay_seconds,
            wave_max_delay_seconds = meta.wave_max_delay_seconds,
            tech_influence = ev.tech_influence,
            tech_tiers = ev.tech_tiers
        }

        schedule_event_for_tick("laser_boss", ship_stub, surface, delay_ticks, next_meta)
        debug("Scheduled next laser_boss wave in " .. tostring(seconds) .. "s (waves left: " .. tostring(next_waves_remaining) .. ") tier=" .. tostring(tier) .. " evo=" .. string.format("%.3f", t.evo) .. " tech=" .. string.format("%.3f", t.tech) .. " comb=" .. string.format("%.3f", t.threat))
    else
        if meta and meta.total_waves then
            debug("Completed all laser_boss waves (total " .. tostring(meta.total_waves) .. ")")
        end
    end
end

ACTIONS.ruins = function(surface, ev, ship_stub, meta)
    if not (surface and surface.valid) then return end

    -- Инициализация состояния ruins
    storage.ruins_active_surfaces = storage.ruins_active_surfaces or {}
    storage.ruins_active_surfaces[surface.index] = true

    -- Сохраняем силу для расчета угрозы при генерации чанков
    storage.ruins_trigger_force_by_surface = storage.ruins_trigger_force_by_surface or {}
    local force_name = nil
    if ship_stub and ship_stub.force then
        if type(ship_stub.force) == "string" then
            force_name = ship_stub.force
        else
            force_name = ship_stub.force.name
        end
    end
    storage.ruins_trigger_force_by_surface[surface.index] = force_name

    -- Включаем обработчик генерации чанков для спавна руин
    sync_chunk_generated_handler()

    game.print({ "wdm-expansion.ruins_discovered", surface.name })
    debug("Ruins event activated on surface " .. tostring(surface.name) .. ". Triggering force: " .. tostring(force_name))
end

--[[
ACTIONS.spawn_pirate_base = function(surface, ev, ship_stub)
    spawn_pirate_base(ship_stub, surface)
end
]]
-- ACTION: Землетрясение - снижает скорость ходьбы всех игроков на поверхности
ACTIONS.earthquake = function(surface, ev, ship_stub, meta)
    if not (surface and surface.valid) then return end

    local ev_cfg = ev or DEFAULT_EVENTS.earthquake
    local base_speed_reduction = ev_cfg.speed_reduction
    if has_active_mod("RPGsystem") then
        base_speed_reduction = -0.6
    end
    local base_duration = ev_cfg.duration_seconds

    -- determine force/context for threat calculation
    local force = nil
    if ship_stub and ship_stub.force and type(ship_stub.force) == "table" then
        force = ship_stub.force
    elseif ship_stub and ship_stub.force and type(ship_stub.force) == "string" then
        force = game.forces[ship_stub.force]
    end
    if not (force and force.valid) then force = game.forces["player"] end

    local t = get_threat_level(surface, force, { tech_weight = ev_cfg.tech_influence or 0.7, tech_tiers = ev_cfg.tech_tiers })

    -- scale duration by threat: higher threat -> longer quake
    local min_mult = 0.5
    local max_mult = 1.5
    local duration_mult = min_mult + (max_mult - min_mult) * t.threat
    local duration_seconds = math.max(1, math.floor(base_duration * duration_mult))
    local duration_ticks = duration_seconds * 60

    -- optionally scale strength of speed reduction by threat (optional, here we keep base but can adapt)
    local speed_reduction = base_speed_reduction -- could be scaled by t.threat if desired

    local surface_index = surface.index

    -- init earthquake record
    local eq_data = {
        affected_players = {},
        speed_reduction = speed_reduction,
        end_tick = game.tick + duration_ticks
    }
    storage.active_earthquakes[surface_index] = eq_data

    -- Включаем on_nth_tick для проверки землетрясений
    if update_tick_handlers then
        update_tick_handlers()
    end

    -- apply modifier to connected players on surface
    for _, player in pairs(game.connected_players) do
        if player.surface and player.surface.valid and player.surface.index == surface_index and player.character then
            local pidx = player.index
            eq_data.affected_players[pidx] = { original_speed = player.character_running_speed_modifier or 0 }
            player.character_running_speed_modifier = (player.character_running_speed_modifier or 0) + speed_reduction
        end
    end

    game.print({ "wdm-expansion.earthquake_started", surface.name, duration_seconds })
    --pcall(function() surface.play_sound{ path = "", volume_modifier = 0.8 } end)

    debug("Earthquake started on surface " .. tostring(surface_index) .. ", affected " .. tostring(table_size(eq_data.affected_players)) .. " players, ends at tick " .. tostring(eq_data.end_tick) .. ", threat=" .. string.format("%.3f", t.threat))
end

ACTIONS.lost_deck = function(surface, ev, ship_stub, meta)
    if not (surface and surface.valid) then return end

    local ev_cfg = ev or DEFAULT_EVENTS.lost_deck
    local base_duration = ev_cfg.duration_seconds or 180

    -- determine force/context for threat calculation
    local force = nil
    if ship_stub and ship_stub.force and type(ship_stub.force) == "table" then
        force = ship_stub.force
    elseif ship_stub and ship_stub.force and type(ship_stub.force) == "string" then
        force = game.forces[ship_stub.force]
    end
    if not (force and force.valid) then force = game.forces["player"] end

    local t = get_threat_level(surface, force, { tech_weight = ev_cfg.tech_influence or 0.7, tech_tiers = ev_cfg.tech_tiers })

    -- scale duration by threat: higher threat -> longer loss
    local min_mult = 0.5
    local max_mult = 1.5
    local duration_mult = min_mult + (max_mult - min_mult) * t.threat
    local duration_seconds = math.max(1, math.floor(base_duration * duration_mult))
    local duration_ticks = duration_seconds * 60

    -- find ship deck surfaces for this force
    local decks = {}
    if force and force.name then
        for _, s in ipairs(collect_ship_floor_surfaces_for_force(force)) do
            local lost = storage.lost_decks and storage.lost_decks[s.index]
            if not (lost and lost.end_tick and game.tick < lost.end_tick) then
                table.insert(decks, s)
            end
        end
    end

    if #decks == 0 then
        debug("lost_deck: no available ship decks for force " .. tostring(force and force.name))
        return
    end

    local target = nil
    while #decks > 0 do
        local idx = math.random(#decks)
        local candidate = table.remove(decks, idx)
        local preferred_pos = { x = 0, y = 0 }
        if force and force.get_spawn_position then
            local ok, spawn_pos = pcall(function()
                return force.get_spawn_position(candidate)
            end)
            if ok and spawn_pos then
                preferred_pos = spawn_pos
            end
        end

        local safe_pos = find_safe_teleport_position and find_safe_teleport_position(candidate, preferred_pos) or nil
        if safe_pos then
            target = candidate
            break
        end

        debug("lost_deck: surface " .. tostring(candidate.name) .. " has no safe teleport position, trying another deck from the pool")
    end

    if not target then
        debug("lost_deck: no ship deck with a safe teleport position for force " .. tostring(force and force.name))
        return
    end

    storage.lost_decks = storage.lost_decks or {}
    storage.lost_decks[target.index] = { end_tick = game.tick + duration_ticks, surface_name = target.name }

    -- Ensure tick handlers are enabled so we enforce prevention and restoration
    if update_tick_handlers then update_tick_handlers() end

    -- Teleport players off the lost deck (use centralized safe teleport helper)
    for _, player in pairs(game.connected_players) do
        if player.surface and player.surface.valid and player.surface.index == target.index then
            local teleported = teleport_player_to_available_deck(player)
            if teleported then player.print({ "wdm-expansion.lost_deck_teleported" }) end
        end
    end

    local minutes = math.ceil(duration_seconds / 60)
    game.print({ "wdm-expansion.lost_deck_started", target.name, minutes })
    debug("lost_deck started on " .. tostring(target.name) .. " for " .. tostring(duration_seconds) .. "s")
end

local function apply_magnetic_storm_on_surface(surface, storm_value, end_tick, silent)
    if not (surface and surface.valid) then return false, nil, nil end

    local previous_value = get_magnetic_storm_value(surface)
    if previous_value == nil then previous_value = 0 end

    local storms = storage.active_magnetic_storms or {}
    local existing = storms[surface.index]

    local effective_end_tick = end_tick
    if existing and existing.end_tick then
        effective_end_tick = math.max(existing.end_tick, end_tick)
    end

    local applied_value = storm_value
    if existing and type(existing.storm_value) == "number" then
        applied_value = math.max(existing.storm_value, storm_value)
    end

    local current_value = applied_value
    local next_reduction_tick = nil
    local reduction_end_tick = nil

    if existing then
        if type(existing.current_value) == "number" then
            current_value = existing.current_value
        end
        if type(existing.next_reduction_tick) == "number" then
            next_reduction_tick = existing.next_reduction_tick
        end
        if type(existing.reduction_end_tick) == "number" then
            reduction_end_tick = existing.reduction_end_tick
        end
    end

    if applied_value > STORM_REDUCTION_TRIGGER_VALUE then
        if current_value >= applied_value then
            current_value = applied_value
            reduction_end_tick = nil
            next_reduction_tick = next_reduction_tick or (game.tick + STORM_REDUCTION_INTERVAL_TICKS)
        else
            current_value = STORM_REDUCTION_VALUE
            reduction_end_tick = reduction_end_tick or (game.tick + STORM_REDUCTION_DURATION_TICKS)
            next_reduction_tick = nil
        end
    else
        current_value = applied_value
        next_reduction_tick = nil
        reduction_end_tick = nil
    end

    if not set_magnetic_storm_value(surface, current_value) then
        debug("electromagnetic_storm: failed to set magnetic-storm property on surface " .. tostring(surface.name))
        return false, nil, nil
    end

    storage.active_magnetic_storms = storage.active_magnetic_storms or {}
    storage.active_magnetic_storms[surface.index] = {
        end_tick = effective_end_tick,
        surface_name = surface.name,
        base_value = (existing and existing.base_value) or previous_value,
        storm_value = applied_value,
        current_value = current_value,
        next_reduction_tick = next_reduction_tick,
        reduction_end_tick = reduction_end_tick,
        silent = silent and true or nil
    }

    local previous_effective_value = (existing and existing.current_value)
    if type(previous_effective_value) ~= "number" then
        previous_effective_value = previous_value
    end
    apply_storm_disable_delta_on_surface(surface, previous_effective_value, current_value)
    if (not existing) and current_value > 0 then
        sync_storm_disable_state_on_surface(surface, current_value)
    end
    return true, applied_value, effective_end_tick
end

local function update_magnetic_storm_cycle(surface, storm_data, now)
    if not (surface and surface.valid and storm_data) then return false end

    local base_value = storm_data.storm_value
    if type(base_value) ~= "number" then
        base_value = get_magnetic_storm_value(surface) or 0
        storm_data.storm_value = base_value
    end

    local current_value = storm_data.current_value
    if type(current_value) ~= "number" then
        current_value = get_magnetic_storm_value(surface) or base_value
    end

    if base_value <= STORM_REDUCTION_TRIGGER_VALUE then
        if current_value ~= base_value then
            if not set_magnetic_storm_value(surface, base_value) then
                debug("electromagnetic_storm: failed to normalize magnetic-storm on surface " .. tostring(surface.name))
                return false
            end
            if not storm_data.silent then
                play_storm_state_change_sound(surface)
            end
            apply_storm_disable_delta_on_surface(surface, current_value, base_value)
            local cache = get_storm_surface_cache(surface.index, false)
            if cache and base_value > 0 and not next(cache.currently_disabled) then
                sync_storm_disable_state_on_surface(surface, base_value)
            end
            storm_data.current_value = base_value
            storm_data.next_reduction_tick = nil
            storm_data.reduction_end_tick = nil
            return true
        end
        storm_data.current_value = base_value
        storm_data.next_reduction_tick = nil
        storm_data.reduction_end_tick = nil
        return false
    end

    local next_reduction_tick = storm_data.next_reduction_tick
    local reduction_end_tick = storm_data.reduction_end_tick
    local target_value = current_value

    if type(reduction_end_tick) == "number" then
        if now >= reduction_end_tick then
            target_value = base_value
            reduction_end_tick = nil
            next_reduction_tick = now + STORM_REDUCTION_INTERVAL_TICKS
        else
            target_value = STORM_REDUCTION_VALUE
        end
    else
        if type(next_reduction_tick) ~= "number" then
            next_reduction_tick = now + STORM_REDUCTION_INTERVAL_TICKS
        end
        if now >= next_reduction_tick then
            target_value = STORM_REDUCTION_VALUE
            reduction_end_tick = now + STORM_REDUCTION_DURATION_TICKS
            next_reduction_tick = nil
        else
            target_value = base_value
        end
    end

    storm_data.next_reduction_tick = next_reduction_tick
    storm_data.reduction_end_tick = reduction_end_tick

    if current_value == target_value then
        storm_data.current_value = current_value
        return false
    end

    if not set_magnetic_storm_value(surface, target_value) then
        debug("electromagnetic_storm: failed to update magnetic-storm on surface " .. tostring(surface.name))
        return false
    end

    if not storm_data.silent then
        play_storm_state_change_sound(surface)
    end
    apply_storm_disable_delta_on_surface(surface, current_value, target_value)
    if target_value > 0 then
        local cache = get_storm_surface_cache(surface.index, false)
        if cache and (current_value > target_value) and not next(cache.currently_disabled) then
            sync_storm_disable_state_on_surface(surface, target_value)
        end
    end
    storm_data.current_value = target_value
    return true
end

collect_ship_floor_surfaces_for_force = function(force)
    if not (force and force.valid and force.name and game and game.surfaces) then
        return {}
    end

    local prefix = "ship_interior_"
    local suffix = "_" .. force.name
    local surfaces = {}

    for _, candidate in pairs(game.surfaces) do
        if candidate and candidate.valid and candidate.name then
            local name = candidate.name
            if string.sub(name, 1, #prefix) == prefix and string.sub(name, -#suffix) == suffix then
                local deck_id = string.sub(name, #prefix + 1, #name - #suffix)
                if deck_id == "h" or string.match(deck_id, "^%d+$") then
                    surfaces[#surfaces + 1] = candidate
                end
            end
        end
    end

    table.sort(surfaces, function(a, b)
        return a.name < b.name
    end)

    return surfaces
end

ACTIONS.electromagnetic_storm = function(surface, ev, ship_stub, meta)
    if not has_active_mod("magnetic-storm") then return end
    if not (surface and surface.valid) then return end

    local ev_cfg = ev or DEFAULT_EVENTS.electromagnetic_storm
    -- determine force/context for threat calculation
    local force = nil
    if ship_stub and ship_stub.force and type(ship_stub.force) == "table" then
        force = ship_stub.force
    elseif ship_stub and ship_stub.force and type(ship_stub.force) == "string" then
        force = game.forces[ship_stub.force]
    end
    if not (force and force.valid) then force = game.forces["player"] end

    local t = get_threat_level(surface, force, { tech_weight = ev_cfg.tech_influence or 0.5, tech_tiers = ev_cfg.tech_tiers })

    -- scale storm value by threat
    local storm_min = clamp(ev_cfg.storm_min or 20, 0, 100)
    local storm_max = clamp(ev_cfg.storm_max or 100, 0, 100)
    if storm_max < storm_min then
        storm_min, storm_max = storm_max, storm_min
    end
    local storm_value = math.floor(storm_min + (storm_max - storm_min) * t.threat + 0.5)
    storm_value = clamp(storm_value, 0, 100)

    local targets = {}
    local seen = {}
    local function add_target(s, silent)
        if s and s.valid and not seen[s.index] then
            seen[s.index] = true
            targets[#targets + 1] = { surface = s, silent = silent and true or false }
        end
    end

    add_target(surface, false)
    for _, deck_surface in ipairs(collect_ship_floor_surfaces_for_force(force)) do
        add_target(deck_surface, deck_surface.index ~= surface.index)
    end

    local applied_count = 0
    local display_surface_name = surface.name
    local display_value = storm_value

    -- use a large tick value so the storm never expires on its own
    local stored_end = math.huge
    local display_end_tick = stored_end

    for _, target in ipairs(targets) do
        local ok, applied_value, effective_end_tick = apply_magnetic_storm_on_surface(target.surface, storm_value, stored_end, target.silent)
        if ok then
            applied_count = applied_count + 1
            if target.surface.index == surface.index then
                display_surface_name = target.surface.name
                display_value = applied_value
                display_end_tick = effective_end_tick
            elseif applied_count == 1 then
                display_surface_name = target.surface.name
                display_value = applied_value
                display_end_tick = effective_end_tick
            end
        end
    end

    if applied_count == 0 then return end

    if update_tick_handlers then update_tick_handlers() end

    local active_seconds = math.max(1, math.ceil((display_end_tick - game.tick) / 60))
    game.print({ "wdm-expansion.electromagnetic_storm_started"})
    debug("electromagnetic_storm started on " .. tostring(applied_count) .. " surfaces; value=" .. tostring(display_value) .. " duration=" .. tostring(active_seconds) .. "s threat=" .. string.format("%.3f", t.threat), display_surface_name, display_value, active_seconds)
end

-- ACTION: crystal_overgrowth - spawn initial crystals and enable growth
ACTIONS.crystal_overgrowth = function(surface, ev, ship_stub, meta)
    if not (surface and surface.valid) then return end
    local cfg = ev or DEFAULT_EVENTS.crystal_overgrowth
    local center = ship_stub and ship_stub.position or nil
    -- determine force for tech lookups (derive from ship)
    local force = nil
    if ship_stub and ship_stub.force and type(ship_stub.force) == "table" then
        force = ship_stub.force
    elseif ship_stub and ship_stub.force and type(ship_stub.force) == "string" then
        force = game.forces[ship_stub.force]
    end
    if not (force and force.valid) then force = game.forces["player"] end

    -- crystal_overgrowth: use tech-based distances; default modifier = 1
    local spawn_opts = {
        force = force,
        spawn_distance_modifier = ev.spawn_distance_modifier or (ev.spawn_opts and ev.spawn_opts.spawn_distance_modifier) or 1
    }
    game.print({ "wdm-expansion.crystal_overgrowth_started", surface.name })
    spawn_crystals(surface, cfg.initial_count or 8, center, nil, true, spawn_opts)
    storage.crystal_overgrowth_active = storage.crystal_overgrowth_active or {}
    storage.crystal_overgrowth_active[surface.index] = force and force.name or "player"
    -- configure tick interval (seconds -> ticks)
    storage.crystal_growth_interval = ((cfg.growth_interval_seconds or 60) * 60)
    ensure_crystal_tick()
    debug("crystal_overgrowth started on surface " .. tostring(surface.index))
end

-- ACTION: bright_day - increases sunlight and extends daytime
ACTIONS.bright_day = function(surface, ev, ship_stub, meta)
    if not (surface and surface.valid) then return end
    
    local cfg = ev or DEFAULT_EVENTS.bright_day
    local solar_mult = cfg.solar_multiplier
    local daytime = cfg.daytime_ratio
    
    -- Boost solar power generation
    if surface.solar_power_multiplier then
        surface.solar_power_multiplier = solar_mult
    end
    
    -- Extend daytime (lower ratio = more day time)
    if surface.daytime then
        surface.daytime = daytime
    end
    
    -- Increase brightness visually
    if surface.brightness_visual_weights then
        surface.brightness_visual_weights = { -0.3, -0.3, -0.3 }
    end
    
--    game.print({ "wdm-expansion.bright_day_started", surface.name })
    debug("bright_day started on surface " .. tostring(surface.name) .. ", solar=" .. tostring(solar_mult) .. " daytime=" .. tostring(daytime))
end

-- GAS LEAK SYSTEM
-- Структура: { [player_index] = { frame = ..., cost_labels = [...], repair_btn = ..., surface_index = ... } }
local gas_leak_gui_cache = {}

local gas_leak_ticker_active = false

-- Хелпер: получить force из ship_stub
local function resolve_force_from_stub(ship_stub)
    if not ship_stub then return game.forces["player"] end
    local force = ship_stub.force
    if type(force) == "table" and force.valid then return force end
    if type(force) == "string" then force = game.forces[force] end
    if force and force.valid then return force end
    return game.forces["player"]
end

-- Хелпер: конфиг gas_leak
local function get_gas_leak_cfg()
    return storage.events and storage.events.gas_leak or DEFAULT_EVENTS.gas_leak
end

-- Проверка, может ли сила производить данный предмет
local function is_item_available_for_force(force, item_name)
    if not (force and force.valid) then return false end
    local recipe = force.recipes[item_name]
    if recipe then
        return recipe.enabled == true
    end
    local item_proto = prototypes.item[item_name]
    if not item_proto then
        return false
    end
    return true
end

-- Генерация случайного repair_cost из пула предметов
local function generate_random_repair_cost(cfg, force)
    if not cfg then return nil end
    
    local pool = cfg.item_pool
    if not pool or #pool == 0 then
        return {}
    end
    
    local available_pool = {}
    for _, item in ipairs(pool) do
        if is_item_available_for_force(force, item.name) then
            available_pool[#available_pool + 1] = item
        end
    end
    
    if #available_pool == 0 then
        return {}
    end
    
    local count = math.min(cfg.repair_items_count or 4, #available_pool)
    local result = {}
    local used_indices = {}
    local attempts = 0
    local max_attempts = count * 3
    while #result < count and attempts < max_attempts do
        attempts = attempts + 1
        local idx = math.random(#available_pool)
        
        -- Проверяем уникальность через хэш-таблицу (O(1))
        if not used_indices[idx] then
            used_indices[idx] = true
            local item = available_pool[idx]
            local item_count = math.random(item.count_min, item.count_max)
            result[#result + 1] = {
                name = item.name,
                count = item_count
            }
        end
    end
    if #result < count then
        for i = 1, #available_pool do
            if not used_indices[i] then
                local item = available_pool[i]
                local item_count = math.random(item.count_min, item.count_max)
                result[#result + 1] = {
                    name = item.name,
                    count = item_count
                }
                if #result >= count then break end
            end
        end
    end
    
    return result
end

-- Получить repair_cost для конкретной утечки (с учетом случайной генерации)
local function get_gas_leak_repair_cost(surface_index)
    if not surface_index then return {} end
    local leak_data = storage.gas_leak_active and storage.gas_leak_active[surface_index]
    if leak_data then
        -- Если repair_cost уже сохранён — возвращаем его
        if leak_data.repair_cost then
            return leak_data.repair_cost
        end
        -- Если нет — генерируем один раз и кешируем обратно в запись
        local force = nil
        if leak_data.force_name and game.forces and game.forces[leak_data.force_name] then
            force = game.forces[leak_data.force_name]
        end
        if not (force and force.valid) then
            force = game.forces["player"]
        end
        local new_cost = generate_random_repair_cost(get_gas_leak_cfg(), force) or {}
        leak_data.repair_cost = new_cost
        return new_cost
    end
    -- Если записи вообще нет — возвращаем пустой массив
    return {}
end

-- Проверка, может ли игрок починить утечку
local function can_repair_gas_leak(player, surface_index)
    if not (player and player.valid) then return false, "no_player" end
    local leak_data = storage.gas_leak_active and storage.gas_leak_active[surface_index]
    if not (leak_data and leak_data.active) then return false, "no_leak" end
    
    local cost = get_gas_leak_repair_cost(surface_index) or {}
    for _, item in ipairs(cost) do
        if player.get_item_count(item.name) < item.count then
            return false, "missing_resources"
        end
    end
    return true, "ok"
end

local GAS_CLOUD_TYPES = {"poison-cloud", "rainbow-mini-poison-cloud", "dangerous-big-poison-cloud"}

local function spawn_gas_clouds_on_surface(surface, center_pos, count, radius)
    if not (surface and surface.valid) then return 0 end
    count = count or 3
    radius = radius or 3
    local spawned = 0
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        -- Дистанция разброса облаков от 0 до radius (radius — это максимальный радиус)
        local dist = math.random() * radius
        local pos = {
            x = (center_pos and center_pos.x or 0) + math.cos(angle) * dist,
            y = (center_pos and center_pos.y or 0) + math.sin(angle) * dist
        }
        if is_non_water_tile(surface, pos) then
            local cloud_name = GAS_CLOUD_TYPES[math.random(#GAS_CLOUD_TYPES)]
            local ok, cloud = pcall(function()
                return surface.create_entity{
                    name = cloud_name,
                    position = pos,
                    force = game.forces.neutral
                }
            end)
            if ok and cloud and cloud.valid then
                spawned = spawned + 1
            end
        end
    end
    return spawned
end

-- Спавнит облака на всех этажах корабля
local function spawn_gas_clouds_on_all_floors(surface, cfg, force, center_pos)
    if not (surface and surface.valid) then return 0 end
    local count = cfg.initial_clouds_per_floor or 3
    local max_radius, initial_radius = get_gas_leak_radius_by_tech(force, surface)
    local total = spawn_gas_clouds_on_surface(surface, center_pos, count, initial_radius)
    
    if force and force.name then
        for _, deck_surface in ipairs(collect_ship_floor_surfaces_for_force(force)) do
            local deck_center = { x = 0, y = 0 }
            if force.get_spawn_position then
                local ok, sp = pcall(function() return force.get_spawn_position(deck_surface) end)
                if ok and sp then deck_center = sp end
            end
            local deck_max_radius, deck_initial_radius = get_gas_leak_radius_by_tech(force, deck_surface)
            total = total + spawn_gas_clouds_on_surface(deck_surface, deck_center, count, deck_initial_radius)
        end
    end
    return total
end

-- Хендлер роста облаков (вызывается из nth_tick)
local function gas_leak_growth_handler()
    if not (storage and storage.gas_leak_active) then return end
    local now = game.tick
    local cfg = get_gas_leak_cfg()
    local growth_count = cfg.cloud_growth_count or 2
    local growth_interval = (cfg.cloud_growth_interval_seconds or 30) * 60
    
    for surface_index, leak_data in pairs(storage.gas_leak_active) do
        if leak_data.active and now >= leak_data.growth_tick then
            local surface = game.surfaces[surface_index]
            if surface and surface.valid then
                local force = nil
                if leak_data.force_name and game.forces and game.forces[leak_data.force_name] then
                    force = game.forces[leak_data.force_name]
                end
                local max_radius, _ = get_gas_leak_radius_by_tech(force, surface)
                local growth_radius = math.random(math.max(2, math.floor(max_radius * 0.3)), max_radius)
                local spawned = spawn_gas_clouds_on_surface(surface, { x = 0, y = 0 }, growth_count, growth_radius)
                leak_data.clouds_count = (leak_data.clouds_count or 0) + spawned
                leak_data.growth_tick = now + growth_interval
                debug("gas_leak growth on surface " .. tostring(surface.name) .. ": +" .. tostring(spawned) .. " clouds (total: " .. tostring(leak_data.clouds_count) .. ", radius: " .. tostring(growth_radius) .. ")")
            else
                leak_data.active = false
            end
        end
    end
end

local COLOR_GREEN = {0.3, 0.8, 0.3}
local COLOR_RED = {0.9, 0.3, 0.3}

local function gas_leak_gui_update_handler()
    if not next(gas_leak_gui_cache) then return end
    
    -- Получаем repair_cost из первой активной утечки (они все одинаковые)
    local sample_surface_index = nil
    for surface_index, _ in pairs(storage.gas_leak_active) do
        sample_surface_index = surface_index
        break
    end
    local cost = sample_surface_index and get_gas_leak_repair_cost(sample_surface_index)
    if not cost or #cost == 0 then
        -- Fallback на дефолтный repair_cost из конфига
        local cfg = get_gas_leak_cfg()
        cost = cfg and cfg.repair_cost
        if not cost or #cost == 0 then return end
    end
    
    local game_players = game.players
    local storage_leaks = storage.gas_leak_active
    
    for player_index, cache in pairs(gas_leak_gui_cache) do
        local player = game_players[player_index]
        if not (player and player.valid) then 
            gas_leak_gui_cache[player_index] = nil 
            goto continue 
        end
        
        local frame = cache.frame
        if not (frame and frame.valid) then 
            gas_leak_gui_cache[player_index] = nil 
            goto continue 
        end
        
        local surface_index = cache.surface_index
        local leak_data = surface_index and storage_leaks and storage_leaks[surface_index]
        if not (leak_data and leak_data.active) then
            gas_leak_gui_cache[player_index] = nil
            goto continue
        end
        
        local main_inv = player.get_main_inventory()
        local cost_labels = cache.cost_labels
        for idx = 1, #cost do
            local item = cost[idx]
            local has_count = main_inv and main_inv.get_item_count(item.name) or 0
            
            local amount_label = cost_labels[idx]
            if amount_label and amount_label.valid then
                amount_label.caption = {"wdm-expansion.gas_leak_cost_amount", item.count, has_count}
                local enough = has_count >= item.count
                local target_color = enough and COLOR_GREEN or COLOR_RED
                
                local style = amount_label.style
                if style.font_color ~= target_color then
                    style.font_color = target_color
                end
            end
        end
    local can_repair = can_repair_gas_leak(player, surface_index)
        local repair_btn = cache.repair_btn
        
        if repair_btn and repair_btn.valid then
            if repair_btn.enabled ~= can_repair then
                repair_btn.enabled = can_repair
            end
            local target_tooltip = not can_repair and {"wdm-expansion.gas_leak_repair_no_resources"} or ""
            if repair_btn.tooltip ~= target_tooltip then
                repair_btn.tooltip = target_tooltip
            end
        end
        
        ::continue::
    end
end

-- Единый nth_tick хендлер для gas_leak
local function gas_leak_nth_tick_handler()
    gas_leak_growth_handler()
    gas_leak_gui_update_handler()
    -- Отключаем тикер только если нет активных утечек
    if gas_leak_ticker_active and not (storage and storage.gas_leak_active and next(storage.gas_leak_active)) then
        script.on_nth_tick(62, nil)
        gas_leak_ticker_active = false
    end
end

-- Включает on_nth_tick(62) если ещё не включён
local function gas_leak_ensure_ticker()
    if not gas_leak_ticker_active then
        script.on_nth_tick(62, gas_leak_nth_tick_handler)
        gas_leak_ticker_active = true
    end
end

-- Пытается выключить on_nth_tick(62)
local function gas_leak_try_stop_ticker()
    if gas_leak_ticker_active and not (storage and storage.gas_leak_active and next(storage.gas_leak_active)) then
        script.on_nth_tick(62, nil)
        gas_leak_ticker_active = false
    end
end

-- ACTION: gas_leak - spawn poison clouds on all ship floors and planet surface
ACTIONS.gas_leak = function(surface, ev, ship_stub, meta)
    if not (surface and surface.valid) then return end
    
    local cfg = ev or DEFAULT_EVENTS.gas_leak
    local force = resolve_force_from_stub(ship_stub)
    local surface_index = surface.index
    local growth_interval = (cfg.cloud_growth_interval_seconds or 30) * 60
    
    -- Генерируем случайную стоимость ремонта с учётом доступных предметов для силы
    local random_repair_cost = generate_random_repair_cost(cfg, force)
    
    storage.gas_leak_active = storage.gas_leak_active or {}
    local leak_entry = {
        active = true,
        force_name = force and force.name or "player",
        growth_tick = game.tick + growth_interval,
        clouds_count = 0,
        repair_cost = random_repair_cost
    }
    
    -- Запись для планеты
    storage.gas_leak_active[surface_index] = leak_entry
    
    -- Записи для этажей
    if force and force.name then
        for _, deck_surface in ipairs(collect_ship_floor_surfaces_for_force(force)) do
            if not storage.gas_leak_active[deck_surface.index] then
                storage.gas_leak_active[deck_surface.index] = {
                    active = true,
                    force_name = force.name or "player",
                    growth_tick = game.tick + growth_interval,
                    clouds_count = 0,
                    repair_cost = random_repair_cost
                }
            end
        end
    end
    
    local center = ship_stub and ship_stub.position or { x = 0, y = 0 }
    local spawned = spawn_gas_clouds_on_all_floors(surface, cfg, force, center)
    
    if update_tick_handlers then update_tick_handlers() end
    
    game.print({ "wdm-expansion.gas_leak_started", surface.name })
    for _, player in pairs(game.connected_players) do
        if player.surface and player.surface.valid and player.surface.index == surface_index then
            open_gas_leak_repair_gui(player, surface_index)
        end
    end
    debug("gas_leak started on surface " .. tostring(surface.name) .. ", initial clouds: " .. tostring(spawned))
end

-- Миграция утечки газа на новую поверхность (при варпе)
local function migrate_gas_leaks_to_new_surface(destination_surface, force)
    if not (storage and storage.gas_leak_active and next(storage.gas_leak_active)) then return end

    local cfg = get_gas_leak_cfg()
    local growth_interval = (cfg.cloud_growth_interval_seconds or 30) * 60

    -- Сохраняем данные из первой активной записи
    local template_entry = nil
    for _, entry in pairs(storage.gas_leak_active) do
        if entry.active then
            template_entry = {
                active = true,
                force_name = entry.force_name or (force and force.name) or "player",
                growth_tick = game.tick + growth_interval,
                clouds_count = entry.clouds_count or 0
            }
            break
        end
    end

    if not template_entry then return end

    -- Уничтожаем все типы облаков на старых поверхностях
    for surface_index, _ in pairs(storage.gas_leak_active) do
        local surface = game.surfaces[surface_index]
        if surface and surface.valid then
            for _, cloud_name in ipairs(GAS_CLOUD_TYPES) do
                for _, cloud in ipairs(surface.find_entities_filtered{name = cloud_name}) do
                    if cloud and cloud.valid then cloud.destroy() end
                end
            end
        end
    end

    -- Очищаем старые записи
    storage.gas_leak_active = {}

    -- Создаем запись для новой планеты
    local new_surface_index = destination_surface.index
    storage.gas_leak_active[new_surface_index] = {
        active = true,
        force_name = template_entry.force_name,
        growth_tick = game.tick + growth_interval,
        clouds_count = 0
    }

    -- Создаем записи для новых этажей корабля
    if force and force.name then
        for _, deck_surface in ipairs(collect_ship_floor_surfaces_for_force(force)) do
            if not storage.gas_leak_active[deck_surface.index] then
                storage.gas_leak_active[deck_surface.index] = {
                    active = true,
                    force_name = force.name or "player",
                    growth_tick = game.tick + growth_interval,
                    clouds_count = 0
                }
            end
        end
    end

    -- Спавним облака на новых поверхностях
    local center = { x = 0, y = 0 }
    spawn_gas_clouds_on_all_floors(destination_surface, cfg, force, center)

    -- Открываем GUI для игроков на новой поверхности
    for _, player in pairs(game.connected_players) do
        if player.surface and player.surface.valid and player.surface.index == new_surface_index then
            open_gas_leak_repair_gui(player, new_surface_index)
        end
    end

    debug("Gas leaks migrated to new surface " .. tostring(destination_surface.name))
end

-- Остановка всех утечек газа
local function stop_all_gas_leaks()
    if not (storage and storage.gas_leak_active) then return end
    for surface_index, _ in pairs(storage.gas_leak_active) do
        local surface = game.surfaces[surface_index]
        if surface and surface.valid then
            -- Уничтожаем все типы газовых облаков
            for _, cloud_name in ipairs(GAS_CLOUD_TYPES) do
                for _, cloud in ipairs(surface.find_entities_filtered{name = cloud_name}) do
                    if cloud and cloud.valid then cloud.destroy() end
                end
            end
        end
    end
    storage.gas_leak_active = {}
    gas_leak_try_stop_ticker()
    debug("All gas leaks stopped")
end

-- Починка утечки газа (забирает ресурсы у игрока)
local function repair_gas_leak(player, surface_index)
    if not (player and player.valid) then return false end
    local leak_data = storage.gas_leak_active and storage.gas_leak_active[surface_index]
    if not (leak_data and leak_data.active) then return false end
    
    local cost = get_gas_leak_repair_cost(surface_index) or {}
    for _, item in ipairs(cost) do
        local inventory = player.get_main_inventory()
        if inventory then
            local removed = inventory.remove({name = item.name, count = item.count})
            if removed < item.count and player.character then
                local char_inv = player.character.get_inventory(defines.inventory.character_main)
                if char_inv then
                    char_inv.remove({name = item.name, count = item.count - removed})
                end
            end
        end
    end
    
    leak_data.active = false
    stop_all_gas_leaks()
    game.print({ "wdm-expansion.gas_leak_floor_repaired", game.surfaces[surface_index] and game.surfaces[surface_index].name or "unknown" })
    debug("gas_leak repaired on surface " .. tostring(surface_index) .. " by player " .. tostring(player.name))
    return true
end

-- Открыть GUI для ремонта системы фильтрации газа
open_gas_leak_repair_gui = function(player, surface_index)
    if not (player and player.valid) then return end
    
    if player.gui.screen["wdm_gas_leak_repair_frame"] then
        player.gui.screen["wdm_gas_leak_repair_frame"].destroy()
    end
    
    local can_repair = can_repair_gas_leak(player, surface_index)
    local cfg = get_gas_leak_cfg()
    local cost = get_gas_leak_repair_cost(surface_index) or cfg.repair_cost or {}
    local main_inv = player.get_main_inventory()
    
    local frame = player.gui.screen.add{
        type = "frame",
        name = "wdm_gas_leak_repair_frame",
        direction = "vertical",
        caption = {"wdm-expansion.has_problem"}
    }
    frame.auto_center = true
    frame.style.width = 400
    
    local title_flow = frame.add{type = "flow", direction = "horizontal"}
    title_flow.style.horizontally_stretchable = true
    title_flow.add{type = "label", caption = {"wdm-expansion.gas_leak_repair_title"}, style = "frame_title"}
    local drag_handle = title_flow.add{type = "empty-widget", style = "draggable_space"}
    drag_handle.style.horizontally_stretchable = true
    drag_handle.drag_target = frame
    title_flow.add{type = "sprite-button", name = "wdm-gas-leak-close", sprite = "utility/close", style = "frame_action_button"}
    
    local desc = frame.add{type = "label", caption = {"wdm-expansion.gas_leak_repair_desc"}}
    desc.style.single_line = false
    for _, pad in ipairs({"top_padding", "left_padding", "right_padding"}) do desc.style[pad] = 8 end
    
    local cost_table = frame.add{type = "table", column_count = 3}
    cost_table.style.horizontally_stretchable = true
    for _, pad in ipairs({"top_padding", "left_padding", "right_padding"}) do cost_table.style[pad] = 8 end
    
    local cost_labels = {}
    for idx, item in ipairs(cost) do
        local has_count = main_inv and main_inv.get_item_count(item.name) or 0
        cost_table.add{type = "sprite", sprite = "item/" .. item.name}
        cost_table.add{type = "label", caption = {"item-name." .. item.name}}
        local amount_label = cost_table.add{
            type = "label",
            caption = {"wdm-expansion.gas_leak_cost_amount", item.count, has_count},
            style = "semibold_label"
        }
        amount_label.style.font_color = (has_count >= item.count) and {0.3, 0.8, 0.3} or {0.9, 0.3, 0.3}
        cost_labels[#cost_labels + 1] = amount_label
    end
    
    local button_flow = frame.add{type = "flow", direction = "horizontal"}
    button_flow.style.horizontal_align = "center"
    button_flow.style.top_padding = 12
    button_flow.style.bottom_padding = 8
    
    local repair_btn = button_flow.add{
        type = "button",
        name = "wdm-gas-leak-repair-btn",
        caption = {"wdm-expansion.gas_leak_repair_button"},
        enabled = can_repair,
        style = "confirm_button"
    }
    repair_btn.style.width = 200
    if not can_repair then repair_btn.tooltip = {"wdm-expansion.gas_leak_repair_no_resources"} end
    repair_btn.tags = { surface_index = surface_index }
    
    gas_leak_gui_cache[player.index] = { frame = frame, cost_labels = cost_labels, repair_btn = repair_btn, surface_index = surface_index }
    gas_leak_ensure_ticker()
    player.opened = frame
end

-- Обработчик клика по GUI gas_leak
local function on_gas_leak_gui_click(event)
    if not (event and event.element and event.player_index) then return end
    local player = game.get_player(event.player_index)
    if not (player and player.valid) then return end
    
    local element = event.element
    if element.name == "wdm-gas-leak-close" then
        if player.gui.screen["wdm_gas_leak_repair_frame"] then player.gui.screen["wdm_gas_leak_repair_frame"].destroy() end
        gas_leak_gui_cache[player.index] = nil
        player.opened = nil
    elseif element.name == "wdm-gas-leak-repair-btn" then
        local surface_index = element.tags and element.tags.surface_index
        if surface_index and repair_gas_leak(player, surface_index) then
            if player.gui.screen["wdm_gas_leak_repair_frame"] then player.gui.screen["wdm_gas_leak_repair_frame"].destroy() end
            gas_leak_gui_cache[player.index] = nil
            gas_leak_try_stop_ticker()
            player.opened = nil
        end
    end
end

-- Обработчик закрытия GUI gas_leak
local function on_gas_leak_gui_closed(event)
    if not (event and event.player_index) then return end
    local player = game.get_player(event.player_index)
    if not (player and player.valid) then return end
    if event.gui_type == defines.gui_type.custom and player.gui.screen["wdm_gas_leak_repair_frame"] then
        player.gui.screen["wdm_gas_leak_repair_frame"].destroy()
        gas_leak_gui_cache[player.index] = nil
    end
end

-- Вспомогательная функция: получить валидный прототип босса
local function get_valid_boss_prototype(tier)
    tier = math.max(1, math.min(10, tier))
    
    local mcu_name = "mind-control-unit-" .. tostring(tier)
    local has_mcu = prototypes.entity[mcu_name] ~= nil
    
    local zombie_name = "maf-boss-zombie-" .. tostring(tier)
    local has_zombie = HAS_ZOMBIE_HORDE and prototypes.entity[zombie_name] ~= nil
    if has_mcu and has_zombie then
        if math.random(1, 100) <= 60 then
            return mcu_name
        else
            return zombie_name
        end
    end
    if has_mcu then return mcu_name end
    if has_zombie then return zombie_name end
    
    return nil
end


-- ACTION: spawn_boss_at_world_edge - spawns a boss at the edge of discovered world
ACTIONS.spawn_boss_at_world_edge = function(surface, ev, ship_stub, meta)
    if not (surface and surface.valid) then return end
    
    local base_count = ev.spawn_count or 1
    local force = nil
    if ship_stub and ship_stub.force and type(ship_stub.force) == "table" then
        force = ship_stub.force
    elseif ship_stub and ship_stub.force and type(ship_stub.force) == "string" then
        force = game.forces[ship_stub.force]
    end
    if not (force and force.valid) then force = game.forces["player"] end
    
    -- Расчет уровня угрозы для выбора босса
    local t = get_threat_level(surface, force, {
        tech_weight = ev.tech_influence or 0.55,
        tech_tiers = ev.tech_tiers
    })
    
    local tier = math.floor(t.threat * 9) + 1
    tier = math.max(1, math.min(10, tier))
    
    -- Получить валидный прототип босса
    local prototype_name = get_valid_boss_prototype(tier)
    if not prototype_name or not prototypes.entity[prototype_name] then
        debug("has_boss_2: ERROR - no valid boss prototype for tier " .. tostring(tier))
        return
    end
    
    -- Найти позицию спавна на краю мира
    local spawn_pos = find_boss_edge_spawn_position(surface, ship_stub, force, ev.edge_distance_from_ship or 150)
    if not spawn_pos then
        debug("has_boss_2: Could not find valid spawn position at world edge on surface " .. tostring(surface.name))
        return
    end
    
    -- Спавн босс-юнитов на краю
    local spawned_units = {}
    
    for i = 1, base_count do
        -- Небольшой разброс позиции
        local spawn_angle = (i - 1) / base_count * 2 * math.pi + (math.random() * 0.3)
        local spawn_distance = 15 + math.random(20)
        
        local unit_pos = {
            x = spawn_pos.x + spawn_distance * math.cos(spawn_angle),
            y = spawn_pos.y + spawn_distance * math.sin(spawn_angle)
        }
        
        -- Найти неколлизионную позицию для юнита
        local safe_pos = unit_pos
        if surface.find_non_colliding_position then
            -- Параметры: (name, center, radius, precision, force_to_ignore)
            local found_safe = surface.find_non_colliding_position(prototype_name, unit_pos, 16, 0.5, nil)
            if found_safe then
                safe_pos = found_safe
            end
        end
        
        -- Проверка что позиция валидна
        if not is_non_water_tile(surface, safe_pos) then
            debug("has_boss_2: Skipped spawn at water tile [" .. string.format("%.1f,%.1f", safe_pos.x, safe_pos.y) .. "]")
            goto continue_spawn
        end
        
        -- Спавн босс-юнита
        local ok, boss = pcall(function()
            return surface.create_entity({
                name = prototype_name,
                position = safe_pos,
                force = game.forces.enemy,
                create_build_effect_smoke = false
            })
        end)
        
        if ok and boss and boss.valid then
            table.insert(spawned_units, boss)
            
            -- Спавн визуального эффекта
            pcall(function()
                surface.create_entity({ name = "explosion", position = boss.position })
            end)
            
            debug("has_boss_2: Spawned boss " .. tostring(prototype_name) .. " at [" .. string.format("%.1f,%.1f", safe_pos.x, safe_pos.y) .. "]")
        else
            debug("has_boss_2: Failed to create boss entity of type " .. tostring(prototype_name) .. " at [" .. string.format("%.1f,%.1f", safe_pos.x, safe_pos.y) .. "]")
        end
        
        ::continue_spawn::
    end
    
    -- Отправить спавненных юнитов к кораблю
    local ship_pos = ship_stub and ship_stub.position or { x = 0, y = 0 }
    for _, unit in ipairs(spawned_units) do
        if unit and unit.valid then
            -- Использовать правильный тип дистракции для враждебных юнитов
            unit_go_to_location(unit, ship_pos, surface, defines.distraction.by_anything_with_health, false)
        end
    end
    
    if #spawned_units > 0 then
--        game.print({ "wdm-expansion.has_boss_2_spawned", spawn_pos.x, spawn_pos.y })
        debug("has_boss_2: Successfully spawned " .. tostring(#spawned_units) .. " boss unit(s) of type '" .. tostring(prototype_name) .. "' on surface " .. tostring(surface.name) .. " tier=" .. tostring(tier) .. " evo=" .. string.format("%.3f", t.evo) .. " threat=" .. string.format("%.3f", t.threat))
    else
        debug("has_boss_2: No units were successfully spawned on surface " .. tostring(surface.name))
    end
end

-- ============================================================
-- EARTHQUAKE HELPERS
-- ============================================================

-- ACTION: Crystal overgrowth - spawns crystals and enables periodic growth
spawn_crystals = function(surface, count, center_pos, blocked_zone, announce_in_chat, opts)
    if not (surface and surface.valid) then return end
    count = count or 4
    opts = opts or {}
    local force = nil
    if opts.force then
        if type(opts.force) == "string" then
            force = (game.forces and game.forces[opts.force])
        elseif type(opts.force) == "table" and opts.force.valid then
            force = opts.force
        end
    end
    if not (force and force.valid) then
        force = game.forces and game.forces["player"]
    end

    local function is_inside_blocked_zone(pos)
        if not (blocked_zone and blocked_zone.position and blocked_zone.radius and pos) then return false end
        return distance(pos, blocked_zone.position) < blocked_zone.radius
    end

    local ev_cfg = (storage and storage.events and storage.events.crystal_overgrowth) or DEFAULT_EVENTS.crystal_overgrowth
    local big_chance = (opts and opts.big_chance) or (ev_cfg and ev_cfg.big_crystal_chance) or 0

    for i = 1, count do
        local pos
        -- use tech-based distances for crystals; center_pos means spawn around ship center
        local min_d, max_d
        if opts.min_dist or opts.max_dist then
            min_d = opts.min_dist or 50
            max_d = opts.max_dist or (min_d + 200)
        else
            min_d, max_d = compute_spawn_distance_range_by_tech(force, opts)
        end
        local angle = math.random() * math.pi * 2
        local dist = min_d + (math.random() * (max_d - min_d))
        if center_pos then
            pos = { x = center_pos.x + math.cos(angle) * dist, y = center_pos.y + math.sin(angle) * dist }
        else
            pos = { x = math.cos(angle) * dist, y = math.sin(angle) * dist }
        end

        if not is_inside_blocked_zone(pos) and surface.find_non_colliding_position then
            local spawn_name = "entity-crystal"
            if big_chance > 0 and math.random() < big_chance and prototypes and prototypes.entity and prototypes.entity["big-crystal"] then
                spawn_name = "big-crystal"
            end
            local safe = surface.find_non_colliding_position(spawn_name, pos, 16, 0.5, false)
            if safe and not is_inside_blocked_zone(safe) then
                pos = safe
            else
                pos = nil
            end
            if pos and not is_inside_blocked_zone(pos) then
                local ok, crystal = pcall(function()
                    return surface.create_entity{ name = spawn_name, position = pos, force = game.forces.neutral }
                end)
                if ok and crystal and crystal.valid then
                    register_crystal_bonus_override(crystal)
                    if announce_in_chat then
                        game.print({ "wdm-expansion.crystal_initial_ping", crystal.gps_tag })
                    end
                end
            end
        end
    end
end

local function crystal_growth_tick(event)
    if not (storage and storage.crystal_overgrowth_active and next(storage.crystal_overgrowth_active)) then
        script.on_nth_tick(storage.crystal_growth_interval or 3600, nil)
        return
    end
    local ev = storage.events and storage.events.crystal_overgrowth or DEFAULT_EVENTS.crystal_overgrowth
    local growth = (ev and ev.growth_count) or 2
    for surface_index, force_name in pairs(storage.crystal_overgrowth_active) do
        local surface = game.surfaces[surface_index]
        if surface and surface.valid then
            local blocked_zone = storage.crystal_overgrowth_blocked_zones and storage.crystal_overgrowth_blocked_zones[surface_index]
            local force = nil
            if type(force_name) == "string" then force = game.forces and game.forces[force_name] end
            if not (force and force.valid) then force = game.forces and game.forces["player"] end
            local spawn_opts = {
                spawn_distance_modifier = (ev and (ev.spawn_distance_modifier or (ev.spawn_opts and ev.spawn_opts.spawn_distance_modifier))) or 1,
                force = force
            }
            spawn_crystals(surface, growth, nil, nil, nil, spawn_opts)
        else
            storage.crystal_overgrowth_active[surface_index] = nil
            if storage.crystal_overgrowth_blocked_zones then
                storage.crystal_overgrowth_blocked_zones[surface_index] = nil
            end
        end
    end
    -- disable tick if no active
    if not next(storage.crystal_overgrowth_active) then
        script.on_nth_tick(storage.crystal_growth_interval or 3600, nil)
    end
end

local function stop_all_crystal_growth()
    if not storage then return end
    storage.crystal_overgrowth_active = {}
    storage.crystal_overgrowth_blocked_zones = {}
    script.on_nth_tick(storage.crystal_growth_interval or 3600, nil)
end

ensure_crystal_tick = function()
    storage.crystal_growth_interval = storage.crystal_growth_interval or ((storage.events and storage.events.crystal_overgrowth and storage.events.crystal_overgrowth.growth_interval_seconds) or DEFAULT_EVENTS.crystal_overgrowth.growth_interval_seconds or 60) * 60
    script.on_nth_tick(storage.crystal_growth_interval, crystal_growth_tick)
end

local function apply_crystal_mined_bonus(bonus_override)
    local ev = storage.events and storage.events.crystal_overgrowth or DEFAULT_EVENTS.crystal_overgrowth
    local bonus = (ev and ev.enemy_bonus_per_crystal) or 0.09
    if type(bonus_override) == "number" then
        bonus = bonus_override
    end

    storage.enemy_melee_damage_bonus = (storage.enemy_melee_damage_bonus or 0) + bonus
    storage.enemy_biological_damage_bonus = (storage.enemy_biological_damage_bonus or 0) + bonus
    storage.pirate_humanoid_damage_bonus = (storage.pirate_humanoid_damage_bonus or 0) + bonus

    pcall(function()
        local f = game.forces and game.forces["enemy"]
        if not (f and f.valid) then return end
        if f.set_ammo_damage_modifier then pcall(function() f.set_ammo_damage_modifier("melee", storage.enemy_melee_damage_bonus) end) end
        if f.set_ammo_damage_modifier then pcall(function() f.set_ammo_damage_modifier("biological", storage.enemy_biological_damage_bonus) end) end
    end)
    pcall(function()
        local f = game.forces and game.forces["pirate"]
        if not (f and f.valid) then return end
        if f.set_ammo_damage_modifier then pcall(function() f.set_ammo_damage_modifier("humanoid_ammo_category", storage.pirate_humanoid_damage_bonus) end) end
    end)
    game.print({"wdm-expansion.crystal_mined", storage.enemy_melee_damage_bonus * 100})
    debug("Crystal mined, enemy melee bonus is now " .. tostring(storage.enemy_melee_damage_bonus)
        .. ", biological bonus is now " .. tostring(storage.enemy_biological_damage_bonus)
        .. ", pirate humanoid bonus is now " .. tostring(storage.pirate_humanoid_damage_bonus))
end

-- Apply melee and biological buffs when crystal is mined
local function on_crystal_mined(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end
    if not (entity.name == "entity-crystal" or entity.name == "big-crystal") then return end

    local destroy_record = consume_crystal_destroy_registration_for_entity(entity)
    local bonus_override = destroy_record and destroy_record.bonus_override or take_crystal_bonus_override(entity)

    if entity.name == "big-crystal" then
        local ev = storage.events and storage.events.crystal_overgrowth or DEFAULT_EVENTS.crystal_overgrowth
        if type(bonus_override) ~= "number" and ev and type(ev.big_crystal_bonus) == "number" then
            bonus_override = ev.big_crystal_bonus
        end
    end

    apply_crystal_mined_bonus(bonus_override)
end

local function apply_enemy_damage_bonuses()
    pcall(function()
        local f = game.forces and game.forces["enemy"]
        if not (f and f.valid) then return end
        if f.set_ammo_damage_modifier then pcall(function() f.set_ammo_damage_modifier("melee", storage.enemy_melee_damage_bonus) end) end
        if f.set_ammo_damage_modifier then pcall(function() f.set_ammo_damage_modifier("biological", storage.enemy_biological_damage_bonus) end) end
    end)
    pcall(function()
        local f = game.forces and game.forces["pirate"]
        if not (f and f.valid) then return end
        if f.set_ammo_damage_modifier then pcall(function() f.set_ammo_damage_modifier("humanoid_ammo_category", storage.pirate_humanoid_damage_bonus) end) end
    end)
end
local function reset_crystal_mined_bonuses()
    if not storage then return 0, 0, 0 end
    local old_melee_bonus = storage.enemy_melee_damage_bonus or 0
    local old_biological_bonus = storage.enemy_biological_damage_bonus or 0
    local old_pirate_humanoid_bonus = storage.pirate_humanoid_damage_bonus or 0
    storage.enemy_melee_damage_bonus = 0
    storage.enemy_biological_damage_bonus = 0
    storage.pirate_humanoid_damage_bonus = 0
    apply_enemy_damage_bonuses()
    debug("Crystal mined bonuses reset from melee=" .. tostring(old_melee_bonus)
        .. ", biological=" .. tostring(old_biological_bonus)
        .. ", pirate humanoid=" .. tostring(old_pirate_humanoid_bonus))
    return old_melee_bonus, old_biological_bonus, old_pirate_humanoid_bonus
end

local function end_earthquake(surface_index)
    local eq_data = storage.active_earthquakes[surface_index]
    if not eq_data or not eq_data.affected_players then return end

    for pidx, pdata in pairs(eq_data.affected_players) do
        local player = game.get_player(pidx)
        if player and player.character then
            player.character_running_speed_modifier = pdata.original_speed or 0
        end
    end

    local surface = game.surfaces[surface_index]
    if surface and surface.valid then
        game.print({ "wdm-expansion.earthquake_ended", surface.name })
    end

    debug("Earthquake ended on surface " .. tostring(surface_index) .. ", restored speed for " .. tostring(table_size(eq_data.affected_players)) .. " players")

    storage.active_earthquakes[surface_index] = nil
    
    -- Отключаем on_nth_tick если землетрясений больше нет
    if update_tick_handlers then
        update_tick_handlers()
    end
end

local function end_lost_deck(surface_index)
    if not storage.lost_decks or not storage.lost_decks[surface_index] then return end
    local data = storage.lost_decks[surface_index]
    local surface = game.surfaces[surface_index]
    if surface and surface.valid then
        game.print({ "wdm-expansion.lost_deck_restored", data.surface_name or surface.name })
    end
    storage.lost_decks[surface_index] = nil
    debug("lost_deck restored on surface " .. tostring(surface_index))
    if update_tick_handlers then update_tick_handlers() end
end

local function end_magnetic_storm(surface_index)
    if not storage.active_magnetic_storms or not storage.active_magnetic_storms[surface_index] then return end
    local data = storage.active_magnetic_storms[surface_index]
    local surface = game.surfaces[surface_index]
    if surface and surface.valid then
        local restore_value = data.base_value
        if type(restore_value) ~= "number" then restore_value = 0 end
        if not set_magnetic_storm_value(surface, restore_value) then
            debug("electromagnetic_storm: failed to restore magnetic-storm on surface " .. tostring(surface.name))
        end
        if not data.silent then
            game.print({ "wdm-expansion.electromagnetic_storm_ended" })
        end
    end
    restore_storm_disabled_on_surface(surface_index)
    storage.active_magnetic_storms[surface_index] = nil
    debug("electromagnetic_storm ended on surface " .. tostring(surface_index))
    if update_tick_handlers then update_tick_handlers() end
end

-- helper that forcibly ends every currently tracked storm
local function end_all_magnetic_storms()
    if not (storage and storage.active_magnetic_storms) then return end
    local list = {}
    for surface_index in pairs(storage.active_magnetic_storms) do
        table.insert(list, surface_index)
    end
    for _, surface_index in ipairs(list) do
        end_magnetic_storm(surface_index)
    end
end

local function restore_player_speed_on_surface_change(player_index, old_surface_index) 
    if not old_surface_index then return end
    if not storage.active_earthquakes or not storage.active_earthquakes[old_surface_index] then return end
    local eq_data = storage.active_earthquakes[old_surface_index]
    if not eq_data.affected_players[player_index] then return end

    local player = game.get_player(player_index)
    if not (player and player.character) then return end

    local original_speed = eq_data.affected_players[player_index].original_speed or 0
    player.character_running_speed_modifier = original_speed
    eq_data.affected_players[player_index] = nil

    debug("Restored speed for player " .. tostring(player_index) .. " after leaving surface " .. tostring(old_surface_index))

    if table_size(eq_data.affected_players) == 0 then
        storage.active_earthquakes[old_surface_index] = nil
    end
end

-- Внешний обработчик on_ship_post_warp (для ship_abilities)
-- Устанавливается из control.lua, вызывается из on_ship_post_warp
local external_ship_post_warp_handler = nil

-- Функция для установки внешнего обработчика on_ship_post_warp
local function set_external_ship_post_warp_handler(handler)
    external_ship_post_warp_handler = handler
end

-- ============================================================
-- ОБРАБОТЧИКИ FACTORIO
-- ============================================================

-- Обработчик события когда планета сгенерирована с кастомными событиями
local function on_custom_planet_event(event)
    if not is_mod_enabled() then return end
    
    local ship = event.ship
    local surface = event.surface
    local events = event.events  -- массив строк с именами событий

    if not (ship and surface and surface.valid and events) then
        debug("Invalid on_custom_planet_event data")
        return
    end

    debug("on_custom_planet_event triggered with events: " .. table.concat(events, ", "))

    -- Обрабатываем каждое событие из списка
    for _, event_name in ipairs(events) do
        if storage.events[event_name] or DEFAULT_EVENTS[event_name] then
            handle_custom_planet_event(event_name, ship, surface)
        else
            debug("Event " .. event_name .. " is not our event, skipping")
        end
    end
end

-- Проверка землетрясений (вызывается через on_nth_tick раз в секунду)
local function check_earthquakes()
    -- Если нет ни активных землетрясений, ни потерянных уровней, отключаем on_nth_tick(60)
    if (not storage.active_earthquakes or not next(storage.active_earthquakes))
        and (not storage.lost_decks or not next(storage.lost_decks))
        and (not storage.active_magnetic_storms or not next(storage.active_magnetic_storms))
        and (not storage.gas_leak_active or not next(storage.gas_leak_active)) then
        script.on_nth_tick(60, nil)
        return
    end

    local now = game.tick

    -- Enforce: teleport players standing on lost decks (no inventory loss)
    if storage.lost_decks and next(storage.lost_decks) then
        for _, player in pairs(game.connected_players) do
            if player and player.valid and player.surface and player.surface.valid then
                local ld = storage.lost_decks[player.surface.index]
                if ld and ld.end_tick and now < ld.end_tick then
                    local teleported = teleport_player_to_available_deck(player)
                    if teleported then player.print({ "wdm-expansion.lost_deck_teleported" }) end
                    debug("Enforced lost_deck prevention for player " .. tostring(player.index) .. " on surface " .. tostring(player.surface and player.surface.name))
                end
            end
        end
    end

    local surfaces_to_end = {}
    
    for surface_index, eq_data in pairs(storage.active_earthquakes) do
        -- Проверяем сначала время окончания (быстрее чем проверка поверхности)
        if eq_data.end_tick and now >= eq_data.end_tick then
            table.insert(surfaces_to_end, surface_index)
        elseif eq_data.end_tick then
            -- Проверяем валидность поверхности только если время еще не прошло
            local surface = game.surfaces[surface_index]
            if not (surface and surface.valid) then
                table.insert(surfaces_to_end, surface_index)
            end
        end
    end
    
    for _, si in ipairs(surfaces_to_end) do 
        end_earthquake(si) 
    end

    -- Обработка окончания "потерянных" уровней
    local surfaces_to_restore = {}
    for surface_index, ld in pairs(storage.lost_decks or {}) do
        if ld.end_tick and now >= ld.end_tick then
            table.insert(surfaces_to_restore, surface_index)
        elseif ld.end_tick then
            local s = game.surfaces[surface_index]
            if not (s and s.valid) then table.insert(surfaces_to_restore, surface_index) end
        end
    end
    for _, si in ipairs(surfaces_to_restore) do
        end_lost_deck(si)
    end

    local storm_surfaces_to_end = {}
    for surface_index, storm_data in pairs(storage.active_magnetic_storms or {}) do
        local s = game.surfaces[surface_index]
        if not (s and s.valid) then
            table.insert(storm_surfaces_to_end, surface_index)
        else
            update_magnetic_storm_cycle(s, storm_data, now)
        end
    end
    for _, si in ipairs(storm_surfaces_to_end) do
        end_magnetic_storm(si)
    end
    
    -- Вызов внешнего обработчика (ship_abilities.on_tick), установленного из control.lua
    if external_nth_tick_handler then
        pcall(external_nth_tick_handler)
    end
    
    -- Если после удаления землетрясений и восстановления уровней их не осталось, отключаем on_nth_tick(60)
    if not next(storage.active_earthquakes)
        and not next(storage.lost_decks or {})
        and not next(storage.active_magnetic_storms or {})
        and not (storage.gas_leak_active and next(storage.gas_leak_active)) then
        script.on_nth_tick(60, nil)
    end
end

-- Обработка scheduled events (вызывается через on_tick только когда есть события)
local function process_scheduled_events()
    local now = game.tick
    
    if not storage.scheduled_events or #storage.scheduled_events == 0 then
        -- Если событий нет, отключаем on_tick
        script.on_event(defines.events.on_tick, nil)
        return
    end
    
    local remaining = {}
    
    for _, job in ipairs(storage.scheduled_events) do
        -- Check for has_boss_2 detection message (at half time)
        if job.name == "has_boss_2" and job.meta and job.meta.detected_message_tick and not job.meta.message_shown then
            if game.tick >= job.meta.detected_message_tick then
                game.print({ "wdm-expansion.has_boss_2_detected" })
                job.meta.message_shown = true
            end
        end
        
        if job.tick <= now then
            local ev = storage.events and storage.events[job.name]
            if ev then
                local surface = job.surface_index and game.surfaces[job.surface_index]
                if surface and surface.valid then
                    local ship_stub = {
                        position = job.ship_info and job.ship_info.pos,
                        force = (job.ship_info and job.ship_info.force_name) and game.forces[job.ship_info.force_name] or nil,
                        active_space_station = (job.ship_info and job.ship_info.station_pos) and { position = job.ship_info.station_pos } or nil
                    }
                    local action = ACTIONS[ev.action_name]
                    if action then
                        local ok, err = pcall(action, surface, ev, ship_stub, job.meta)
                        if not ok then debug("Error executing scheduled event '" .. job.name .. "': " .. tostring(err)) end
                    else
                        debug("No action found for scheduled event '" .. job.name .. "'")
                    end
                else
                    debug("Surface invalid for scheduled event: " .. tostring(job.name))
                end
            else
                debug("Scheduled job references unknown event: " .. tostring(job.name))
            end
        else
            table.insert(remaining, job)
        end
    end
    
    storage.scheduled_events = remaining
    
    -- Если после обработки событий их не осталось, отключаем on_tick
    if #storage.scheduled_events == 0 then
        script.on_event(defines.events.on_tick, nil)
    end
end

-- Функция для включения/выключения обработчиков на основе наличия активных событий
update_tick_handlers = function()
    local has_scheduled = storage.scheduled_events and #storage.scheduled_events > 0
    local has_earthquakes = storage.active_earthquakes and next(storage.active_earthquakes)
    local has_lost = storage.lost_decks and next(storage.lost_decks)
    local has_storms = storage.active_magnetic_storms and next(storage.active_magnetic_storms)
    local has_gas_leaks = storage.gas_leak_active and next(storage.gas_leak_active)
    
    -- Включаем on_tick только если есть scheduled events
    if has_scheduled then
        script.on_event(defines.events.on_tick, process_scheduled_events)
    else
        script.on_event(defines.events.on_tick, nil)
    end
    
    -- on_nth_tick(60) нужен для землетрясений, потерянных уровней, цикла магнитного шторма
    if has_earthquakes or has_lost or has_storms then
        script.on_nth_tick(60, check_earthquakes)
    else
        script.on_nth_tick(60, nil)
    end
    
    -- on_nth_tick(62) управляется централизованно через gas_leak_ensure_ticker / gas_leak_try_stop_ticker
    if has_gas_leaks then
        gas_leak_ensure_ticker()
    else
        gas_leak_try_stop_ticker()
    end

    if has_earthquakes or has_lost then
        script.on_event(defines.events.on_player_changed_surface, on_player_changed_surface)
    else
        script.on_event(defines.events.on_player_changed_surface, nil)
    end
end


local function on_player_changed_surface(event)
    if not event.player_index then return end
    local player = game.get_player(event.player_index)
    if not player then return end

    local old_surface_index = event.old_surface_index
    if old_surface_index and storage.active_earthquakes and storage.active_earthquakes[old_surface_index] then
        restore_player_speed_on_surface_change(event.player_index, old_surface_index)
    end

    local new_surface = player.surface
    if new_surface and new_surface.valid and storage.active_earthquakes then
        local eq_data = storage.active_earthquakes[new_surface.index]
        if eq_data and eq_data.speed_reduction and eq_data.end_tick and game.tick < eq_data.end_tick then
            if player.character then
                if not eq_data.affected_players[event.player_index] then
                    eq_data.affected_players[event.player_index] = { original_speed = player.character_running_speed_modifier or 0 }
                    player.character_running_speed_modifier = (player.character_running_speed_modifier or 0) + eq_data.speed_reduction
                    debug("Applied earthquake speed modifier to player " .. tostring(event.player_index) .. " on surface " .. tostring(new_surface.index))
                end
            end
        end
    end

    -- Prevent entering lost decks: teleport player off lost deck using capsule-style teleport (no inventory loss)
    if new_surface and new_surface.valid and storage.lost_decks and storage.lost_decks[new_surface.index] then
        local ld = storage.lost_decks[new_surface.index]
        if ld.end_tick and game.tick < ld.end_tick then
            local teleported = teleport_player_to_available_deck(player)
            if teleported then
                player.print({ "wdm-expansion.lost_deck_teleported" })
                debug("Prevented player " .. tostring(event.player_index) .. " from entering lost deck " .. tostring(new_surface.name))
            else
                debug("Prevented player " .. tostring(event.player_index) .. " from entering lost deck but no destination found")
            end
        end
    end
end


local function on_chunk_generated(event)
    if not is_mod_enabled() then return end
    if not event or not event.surface or not event.surface.valid then return end

    local surface = event.surface
    local surface_index = surface.index
    local ev = storage.events and storage.events.ruins or DEFAULT_EVENTS.ruins
    if not ev then return end

    storage.ruins_active_surfaces = storage.ruins_active_surfaces or {}
    if not storage.ruins_active_surfaces[surface_index] then return end

    local chance = tonumber(ev.chunk_spawn_chance) or 0
    if chance <= 0 or math.random() > chance then return end

    local chunk_position = event.position or event.chunk_position
    if not chunk_position then return end

    local area = event.area
    if not area then
        local left_top = { x = chunk_position.x * 32, y = chunk_position.y * 32 }
        area = {
            left_top = left_top,
            right_bottom = { x = left_top.x + 32, y = left_top.y + 32 }
        }
    end

    local pool = ev.blueprint_pool or get_ruins_blueprint_pool()
    if not (pool and #pool > 0) then return end

    local max_attempts = tonumber(ev.spawn_attempts) or 3
    for _ = 1, max_attempts do
        local blueprint_string = pick_ruins_blueprint_from_pool(pool)
        local trigger_force_name = storage.ruins_trigger_force_by_surface and storage.ruins_trigger_force_by_surface[surface_index]
        local trigger_force = nil
        if trigger_force_name and game.forces and game.forces[trigger_force_name] then
            trigger_force = game.forces[trigger_force_name]
        end
        if not trigger_force then
            for _, p in pairs(game.connected_players) do
                if p and p.valid and p.surface and p.surface.index == surface_index then
                    trigger_force = p.force
                    if trigger_force and trigger_force.valid then
                        debug("Inferred trigger force '" .. tostring(trigger_force.name) .. "' from player " .. tostring(p.index))
                        break
                    end
                end
            end
        end
        if not (trigger_force and trigger_force.valid) then trigger_force = game.forces["player"] end
        
        -- Пытаемся заспавнить руины
        local ok = spawn_ruins_blueprint(surface, area, blueprint_string, {
            force = trigger_force,
            tech_influence = ev.tech_influence,
            tech_tiers = ev.tech_tiers
        })
        
        if ok then
            debug("Ruins spawned on surface " .. tostring(surface.name) .. " at chunk X:" .. tostring(chunk_position.x) .. " Y:" .. tostring(chunk_position.y))
            return
        end
    end
end


local function on_player_joined_game(event)
    if not event.player_index then return end
    local player = game.get_player(event.player_index)
    if not (player and player.surface and player.surface.valid) then return end

    local surface_index = player.surface.index
    local eq_data = storage.active_earthquakes[surface_index]
    if eq_data and eq_data.speed_reduction and eq_data.end_tick and game.tick < eq_data.end_tick then
        if player.character then
            if not eq_data.affected_players[event.player_index] then
                eq_data.affected_players[event.player_index] = { original_speed = player.character_running_speed_modifier or 0 }
                player.character_running_speed_modifier = (player.character_running_speed_modifier or 0) + eq_data.speed_reduction
                debug("Applied earthquake speed modifier to joined player " .. tostring(event.player_index) .. " on surface " .. tostring(surface_index))
            end
        end
    end

    -- If player joined on a lost deck, teleport them away
    local ld = storage.lost_decks and storage.lost_decks[surface_index]
    if ld and ld.end_tick and game.tick < ld.end_tick then
        local teleported = teleport_player_to_available_deck(player)
        if teleported then player.print({ "wdm-expansion.lost_deck_teleported" }) end
    end
end


-- Helper: teleport player to an available ship deck (no inventory penalty)
local function is_real_tile(surface, position)
    if not (surface and surface.valid and position) then return false end
    local ok, tile = pcall(function()
        return surface.get_tile(position)
    end)
    if not (ok and tile and tile.valid and tile.name) then return false end
    return tile.name ~= "out-of-map"
end

local function get_valid_spawn_position(surface, force)
    if not (surface and surface.valid) then return nil end
    local spawn_pos = nil
    if force and force.get_spawn_position then
        local ok, pos = pcall(function()
            return force.get_spawn_position(surface)
        end)
        if ok and pos then spawn_pos = pos end
    end
    if not spawn_pos then
        spawn_pos = { x = 0, y = 0 }
    end
    local safe_pos = (find_safe_teleport_position and find_safe_teleport_position(surface, spawn_pos)) or nil
    if not (safe_pos and is_real_tile(surface, safe_pos)) then return nil end
    return safe_pos
end

local function resolve_surface_ref(surface_ref)
    if not surface_ref then return nil end
    if type(surface_ref) == "number" or type(surface_ref) == "string" then
        local s = game.surfaces[surface_ref]
        if s and s.valid then return s end
        return nil
    end
    if type(surface_ref) == "table" then
        local by_index = surface_ref.index and game.surfaces[surface_ref.index] or nil
        if by_index and by_index.valid then return by_index end
        local by_name = surface_ref.name and game.surfaces[surface_ref.name] or nil
        if by_name and by_name.valid then return by_name end
    end
    local ok_valid, is_valid = pcall(function() return surface_ref.valid end)
    if ok_valid and is_valid then
        return surface_ref
    end
    return nil
end

local function get_ship_planet_surface(force)
    if not (force and force.name and remote.interfaces["WDM"]) then return nil end
    local ok, planet_info = pcall(function()
        return remote.call("WDM", "get_ship_planet_info", force.name)
    end)
    if not (ok and planet_info) then return nil end
    return resolve_surface_ref(planet_info.surface or planet_info.surface_name or planet_info.surface_index)
end

teleport_player_to_available_deck = function(player)
    if not (player and player.valid) then return false end
    local force = player.force
    local current_surface_index = (player.surface and player.surface.valid and player.surface.index) or nil
    local alt = nil
    local alt_spawn_pos = nil
    if force and force.name then
        for _, s in ipairs(collect_ship_floor_surfaces_for_force(force)) do
            local lost = storage.lost_decks and storage.lost_decks[s.index]
            local is_lost = (lost and lost.end_tick and game.tick < lost.end_tick)
            -- Never select the deck the player currently stands on.
            local is_current_deck = current_surface_index and s.index == current_surface_index
            if not is_lost and not is_current_deck then
                local safe_pos = get_valid_spawn_position(s, force)
                if safe_pos then
                    alt = s
                    alt_spawn_pos = safe_pos
                    break
                end
            end
        end
    end

    if alt and alt_spawn_pos then
        player.teleport(alt_spawn_pos, alt)
        return true
    end

    if force and force.name then
        local planet_surface = get_ship_planet_surface(force)
        if planet_surface and planet_surface.valid and (not current_surface_index or planet_surface.index ~= current_surface_index) then
            local planet_safe_pos = get_valid_spawn_position(planet_surface, force)
            if planet_safe_pos then
                player.teleport(planet_safe_pos, planet_surface)
                return true
            end
        end
    end

    return false
end

-- Helper: find a non-colliding position for a player on a surface near preferred position
find_safe_teleport_position = function(surface, preferred_pos)
    if not (surface and surface.valid) then return nil end
    local pos = preferred_pos or { x = 0, y = 0 }
    -- First try the direct non-colliding helper
    local ok, safe = pcall(function()
        return surface.find_non_colliding_position("character", pos, 32, 0.5, false)
    end)
    if ok and safe and is_real_tile(surface, safe) then return safe end

    -- Fallback: radial search outward
    for r = 2, 32, 2 do
        local steps = 12
        for j = 0, steps - 1 do
            local angle = (2 * math.pi) * (j / steps)
            local try_pos = { x = pos.x + math.cos(angle) * r, y = pos.y + math.sin(angle) * r }
            local ok2, safe2 = pcall(function()
                return surface.find_non_colliding_position("character", try_pos, 2, 0.5, false)
            end)
            if ok2 and safe2 and is_real_tile(surface, safe2) then return safe2 end
        end
    end

    -- Last resort: use preferred position only if it has a real tile.
    if is_real_tile(surface, pos) then
        return pos
    end
    return nil
end

-- Обработчик использования предмета экстренного возврата к кораблю
-- ============================================================
-- РЕГИСТРАЦИЯ ИНИЦИАЛИЗАЦИЯ
-- ============================================================

-- WDM ship warp event handler (only warping)
local function on_ship_warping(event)
    -- event.ship, event.is_going_to_planet, event.destination_surface
    debug("WDM event on_ship_warping fired; ship=" .. tostring(event and event.ship and event.ship.name) ..
          ", to_planet=" .. tostring(event and event.is_going_to_planet))

    cleanup_triggered_surface_events()

    local old_melee_bonus = storage.enemy_melee_damage_bonus or 0
    local old_biological_bonus = storage.enemy_biological_damage_bonus or 0
    local old_pirate_humanoid_bonus = storage.pirate_humanoid_damage_bonus or 0
    local new_melee_bonus = old_melee_bonus
    local new_biological_bonus = old_biological_bonus
    local new_pirate_humanoid_bonus = old_pirate_humanoid_bonus

    if old_melee_bonus > 0 then
        new_melee_bonus = math.max(0, old_melee_bonus - 0.015)
    end
    if old_biological_bonus > 0 then
        new_biological_bonus = math.max(0, old_biological_bonus - 0.015)
    end
    if old_pirate_humanoid_bonus > 0 then
        new_pirate_humanoid_bonus = math.max(0, old_pirate_humanoid_bonus - 0.015)
    end
    -- ОСТАНОВКА ГЕНЕРАЦИИ РУИН
    if storage and storage.ruins_active_surfaces then
        storage.ruins_active_surfaces = {} -- Очищаем список поверхностей
        sync_chunk_generated_handler()      -- Отключаем сам обработчик событий (on_event = nil)
        debug("Ruins generation stopped due to ship warp")
    end

    cleanup_triggered_surface_events()
    if new_melee_bonus ~= old_melee_bonus or new_biological_bonus ~= old_biological_bonus or new_pirate_humanoid_bonus ~= old_pirate_humanoid_bonus then
        storage.enemy_melee_damage_bonus = new_melee_bonus
        storage.enemy_biological_damage_bonus = new_biological_bonus
        storage.pirate_humanoid_damage_bonus = new_pirate_humanoid_bonus
        apply_enemy_damage_bonuses()
        debug("Ship warp reduced enemy bonuses: melee "
            .. string.format("%.3f", old_melee_bonus) .. " -> " .. string.format("%.3f", new_melee_bonus)
            .. ", biological "
            .. string.format("%.3f", old_biological_bonus) .. " -> " .. string.format("%.3f", new_biological_bonus)
            .. ", pirate humanoid "
            .. string.format("%.3f", old_pirate_humanoid_bonus) .. " -> " .. string.format("%.3f", new_pirate_humanoid_bonus))
    else
        debug("Ship warp left enemy bonuses unchanged: melee="
            .. string.format("%.3f", old_melee_bonus)
            .. ", biological=" .. string.format("%.3f", old_biological_bonus)
            .. ", pirate humanoid=" .. string.format("%.3f", old_pirate_humanoid_bonus))
    end

    if storage and storage.crystal_overgrowth_active and next(storage.crystal_overgrowth_active) then
        stop_all_crystal_growth()
        debug("All active crystal growth ended due to ship warp")
    end
    if has_active_mod("magnetic-storm") then
        -- stop any active storms immediately when a warp happens
        end_all_magnetic_storms()
        debug("All active magnetic storms ended due to ship warp")

        -- when a ship warps we may also have left a surface with storm-disabled entities,
        -- or arrived somewhere; restore them just in case
        if event and event.destination_surface and event.destination_surface.valid then
            restore_storm_disabled_on_surface(event.destination_surface.index)
            debug("Called restore_storm_disabled_on_surface for surface " .. tostring(event.destination_surface.name))
        end
        -- also clear any leftover records on all surfaces (quiet no-op if none)
        restore_all_storm_disabled_entities()
        storage.storm_tracked_entities = {}
    end
    
    if event and event.ship and event.ship.force then
        terminal_drain.on_ship_warped_handler(event.ship.force_name, event.ship.force, event.destination_surface)
    end
end

-- WDM ship post-warp event handler (called AFTER warp completes, surface is ready)
local function on_ship_post_warp(event)
    -- event.ship, event.destination_surface (может быть nil при варпе в космос)
    -- Используем event.ship.actual_surface как надёжный источник (как в ship_abilities)
    local ship = event and event.ship
    local actual_surface = ship and ship.actual_surface
    debug("WDM event on_ship_post_warp fired; ship=" .. tostring(ship and ship.name) ..
          ", actual_surface=" .. tostring(actual_surface and actual_surface.name))

    -- МИГРАЦИЯ УТЕЧКИ ГАЗА НА НОВУЮ ПОВЕРХНОСТЬ
    -- Здесь поверхность уже полностью готова, можно безопасно мигрировать облака
    if storage and storage.gas_leak_active and next(storage.gas_leak_active) then
        if actual_surface and actual_surface.valid then
            local warp_force = nil
            if ship then
                if ship.force_name then
                    warp_force = game.forces[ship.force_name]
                elseif ship.force and type(ship.force) == "userdata" and ship.force.valid then
                    warp_force = ship.force
                elseif ship.force and type(ship.force) == "string" then
                    warp_force = game.forces[ship.force]
                end
            end
            migrate_gas_leaks_to_new_surface(actual_surface, warp_force)
            debug("Gas leaks migrated on post_warp to " .. tostring(actual_surface.name))
        else
            -- fallback: если нет целевой поверхности
            stop_all_gas_leaks()
            debug("All gas leaks stopped due to ship post-warp (no actual surface)")
        end
    end
    
    -- Вызов внешнего обработчика (ship_abilities.on_ship_post_warp), установленного из control.lua
    if external_ship_post_warp_handler then
        pcall(external_ship_post_warp_handler, event)
    end
end

-- Register WDM ship post-warp event
local function register_wdm_ship_post_warp_handler()
    if not remote.interfaces["WDM"] then
        debug("WDM interface not found, will retry later")
        return false
    end

    local ok, event_id = pcall(function()
        return remote.call("WDM", "get_on_ship_post_warp")
    end)
    if ok and event_id then
        debug("[wdm-expansion] Registering on_ship_post_warp handler for gas_leak, event_id=" .. tostring(event_id))
        script.on_event(event_id, function(event)
            debug("[wdm-expansion] on_ship_post_warp fired (planetary_events)")
            if on_ship_post_warp then
                on_ship_post_warp(event)
            end
        end)
        return true
    else
        debug("[wdm-expansion] Failed to get on_ship_post_warp event_id: " .. tostring(event_id or "nil"))
        return false
    end
end

-- Register WDM ship warping event only
local function register_wdm_ship_warp_events()
    if not remote.interfaces["WDM"] then
        debug("WDM interface not found, will retry later")
        return false
    end
    local any = false

    local ok, id = pcall(function() return remote.call("WDM", "get_on_ship_warping") end)
    if ok and id then
        script.on_event(id, on_ship_warping)
        debug("Registered WDM on_ship_warping successfully")
        any = true
    end

    return any
end

-- Регистрация обработчика события on_custom_planet_event
local function register_wdm_custom_planet_event()
    if not remote.interfaces["WDM"] then
        debug("WDM interface not found, will retry later")
        return false
    end
    
    local id = nil
    local ok, res = pcall(function() return remote.call("WDM", "get_on_custom_planet_event") end)
    if ok then id = res end
    
    if id then
        script.on_event(id, on_custom_planet_event)
        debug("Registered WDM on_custom_planet_event successfully")
        return true
    else
        debug("WDM returned nil for get_on_custom_planet_event")
        return false
    end
end


local function should_enable_chunk_generated_handler()
    return is_mod_enabled()
        and storage
        and storage.ruins_active_surfaces
        and next(storage.ruins_active_surfaces) ~= nil
end

sync_chunk_generated_handler = function()
    if should_enable_chunk_generated_handler() then
        script.on_event(defines.events.on_chunk_generated, on_chunk_generated)
    else
        script.on_event(defines.events.on_chunk_generated, nil)
    end
end

-- Функция для регистрации обработчиков без изменения storage (для on_load)
local function register_event_handlers()
    -- Обработчик экстренного возврата всегда активен, независимо от состояния мода
    if is_mod_enabled() then
        -- Регистрируем события в WDM
        register_wdm_planet_events()

        -- Регистрируем обработчики различных событий WDM
        register_wdm_custom_planet_event()
        register_wdm_ship_warp_events()
        
        -- on_tick и on_nth_tick будут включаться автоматически при появлении событий
        -- через update_tick_handlers(). on_player_changed_surface также управляется там.
        script.on_event(defines.events.on_player_joined_game, on_player_joined_game)
        
        -- Проверяем существующие события после загрузки и включаем обработчики если нужно
        update_tick_handlers()
        
        debug("WDM Boss Expansion mod ENABLED - event handlers registered")
    else
        -- Отключаем все tick-based обработчики (кроме экстренного возврата)
        script.on_event(defines.events.on_tick, nil)
        script.on_nth_tick(60, nil)
        script.on_event(defines.events.on_player_changed_surface, nil)
        script.on_event(defines.events.on_player_joined_game, nil)
        -- gas_leak тикер отключается через централизованную функцию
        gas_leak_try_stop_ticker()
        -- Отменяем регистрацию обработчиков WDM-событий
        if remote.interfaces["WDM"] then
            local ok, id
            ok, id = pcall(function() return remote.call("WDM", "get_on_custom_planet_event") end)
            if ok and id then script.on_event(id, nil) end
        end
        debug("WDM Boss Expansion mod DISABLED - event handlers unregistered")
    end
    register_wdm_ship_post_warp_handler()
    sync_chunk_generated_handler()

    -- Применяем настройку дружественного урона независимо от включенности
    -- основных ивентов мода, т.к. она отвечает только за поведение сил.
    apply_friendly_fire_setting()
end

local function initialize_mod()
    init_event_storage()
    ensure_turret_delay_artillery_support()
    cleanup_triggered_surface_events()
    rebuild_storm_destroy_registrations()
    sync_default_events()
    register_event_handlers()
    sync_chunk_generated_handler()
    if storage.crystal_overgrowth_active and next(storage.crystal_overgrowth_active) then
        ensure_crystal_tick()
    end

    if storage.active_magnetic_storms and next(storage.active_magnetic_storms) then
        for surface_index, storm_data in pairs(storage.active_magnetic_storms) do
            local surface = game.surfaces[surface_index]
            if surface and surface.valid then
                ensure_storm_entity_cache_for_surface(surface)

                local storm_value = storm_data and storm_data.storm_value
                if type(storm_value) ~= "number" then
                    storm_value = get_magnetic_storm_value(surface) or 0
                    storm_data.storm_value = storm_value
                end

                local current_value = storm_data.current_value
                if type(current_value) ~= "number" then
                    current_value = get_magnetic_storm_value(surface) or storm_value
                    storm_data.current_value = current_value
                end

                if storm_value > STORM_REDUCTION_TRIGGER_VALUE then
                    if current_value >= storm_value then
                        storm_data.current_value = storm_value
                        storm_data.reduction_end_tick = nil
                        storm_data.next_reduction_tick = storm_data.next_reduction_tick or (game.tick + STORM_REDUCTION_INTERVAL_TICKS)
                    else
                        storm_data.current_value = STORM_REDUCTION_VALUE
                        storm_data.next_reduction_tick = nil
                        storm_data.reduction_end_tick = storm_data.reduction_end_tick or (game.tick + STORM_REDUCTION_DURATION_TICKS)
                    end
                else
                    storm_data.current_value = storm_value
                    storm_data.next_reduction_tick = nil
                    storm_data.reduction_end_tick = nil
                end

                local effective_value = storm_data.current_value
                set_magnetic_storm_value(surface, effective_value)
                apply_storm_disable_delta_on_surface(surface, storm_data.base_value or 0, effective_value)
                local cache = get_storm_surface_cache(surface.index, false)
                if cache and effective_value > 0 and not next(cache.currently_disabled) then
                    sync_storm_disable_state_on_surface(surface, effective_value)
                end
            else
                restore_storm_disabled_on_surface(surface_index)
            end
        end
    end
    
    if not is_mod_enabled() then
        storage.scheduled_events = {}

        if storage.active_earthquakes and next(storage.active_earthquakes) then
            for surface_index, eq_data in pairs(storage.active_earthquakes) do
                if eq_data and eq_data.affected_players then
                    for player_index, player_data in pairs(eq_data.affected_players) do
                        local player = game.get_player(player_index)
                        if player and player.character then
                            player.character_running_speed_modifier = player_data.original_speed or 0
                        end
                    end
                end
            end
            storage.active_earthquakes = {}
        end

        if storage.active_magnetic_storms and next(storage.active_magnetic_storms) then
            for surface_index, storm_data in pairs(storage.active_magnetic_storms) do
                local surface = game.surfaces[surface_index]
                if surface and surface.valid then
                    local restore_value = storm_data and storm_data.base_value or 0
                    if type(restore_value) ~= "number" then restore_value = 0 end
                    set_magnetic_storm_value(surface, restore_value)
                end
                restore_storm_disabled_on_surface(surface_index)
            end
            storage.active_magnetic_storms = {}
        end

        restore_all_storm_disabled_entities()
    end
end

local function on_surface_deleted(event)
    if not event then return end
    storage.triggered_surface_events = storage.triggered_surface_events or {}
    storage.ruins_active_surfaces = storage.ruins_active_surfaces or {}
    local si_key = event.surface_index and ("surface-index:" .. tostring(event.surface_index)) or nil
    local s_name_key = event.surface_name and ("surface:" .. tostring(event.surface_name)) or nil

    if si_key then
        local evs = storage.triggered_surface_events[si_key]
        if not evs or not next(evs) then
            storage.triggered_surface_events[si_key] = nil
        end
        storage.ruins_active_surfaces[event.surface_index] = nil
        sync_chunk_generated_handler()
    end
    if s_name_key then
        local evs = storage.triggered_surface_events[s_name_key]
        if not evs or not next(evs) then
            storage.triggered_surface_events[s_name_key] = nil
        end
    end
end


-- Обработчик изменения настроек
local function on_runtime_mod_setting_changed(event)
    if event.setting == "wdm-expansion-event-enable" then
        debug("Setting wdm-expansion-event-enable changed, reinitializing mod...")
        initialize_mod()
    elseif event.setting == "wdm-expansion-disable-friendly-fire" then
        debug("Setting wdm-expansion-disable-friendly-fire changed, applying friendly fire state...")
        apply_friendly_fire_setting()
    end
end

local function on_entity_built(event)
    local entity = event.entity or event.created_entity
--    register_crystal_bonus_override(entity)
    apply_artillery_turret_delay(entity)
    apply_storm_disable_to_built_entity(entity)
end

local function on_entity_removed(event)
    on_crystal_mined(event)
    remove_storm_disabled_record_for_entity(event.entity)
    remove_storm_tracked_record_for_entity(event.entity)
end

local function on_object_destroyed(event)
    local crystal_registrations = storage and storage.crystal_destroy_registrations
    if crystal_registrations then
        local crystal_record = crystal_registrations.by_registration[event.registration_number]
        if crystal_record then
            crystal_registrations.by_registration[event.registration_number] = nil
            if crystal_record.key then
                crystal_registrations.by_key[crystal_record.key] = nil
                if storage.crystal_bonus_overrides then
                    storage.crystal_bonus_overrides[crystal_record.key] = nil
                end
            end
            -- Temporarily disable crystal bonus growth from on_object_destroyed.
            -- apply_crystal_mined_bonus(crystal_record.bonus_override)
            return
        end
    end

    local registrations = storage and storage.storm_destroy_registrations
    if not registrations then return end

    local record = registrations.by_registration[event.registration_number]
    if not record then return end
    remove_storm_records_by_key(record.surface_index, record.key)
end

local function on_load()
    ensure_turret_delay_artillery_support()
    register_event_handlers()
    if storage.crystal_overgrowth_active and next(storage.crystal_overgrowth_active) then
        ensure_crystal_tick()
    end
    gas_leak_gui_cache = {}
    if game and game.players then
        for _, player in pairs(game.players) do
            if player and player.valid and player.gui and player.gui.screen then
                local old_frame = player.gui.screen["wdm_gas_leak_repair_frame"]
                if old_frame and old_frame.valid then
                    old_frame.destroy()
                end
            end
        end
    end
    if storage and storage.gas_leak_active and next(storage.gas_leak_active) then
        script.on_nth_tick(2, function()
            if game and game.players then
                for _, player in pairs(game.players) do
                    if player and player.valid and player.surface and player.surface.valid then
                        local leak_data = storage.gas_leak_active[player.surface.index]
                        if leak_data and leak_data.active then
                            open_gas_leak_repair_gui(player, player.surface.index)
                        end
                    end
                end
            end
            script.on_nth_tick(2, nil)
        end)
    end
end

-- Debug console commands
if commands and commands.add_command then
    commands.add_command("wdm-print-ship-force", "Print current ship.force (player vehicle) or player's force.", function(cmd)
        local prefix = "[WDM] ship.force: "
        if cmd and cmd.player_index then
            local player = game.players[cmd.player_index]
            if player and player.valid then
                local ship = player.vehicle
                local force_name = nil
                if ship and ship.valid and ship.force and ship.force.name then
                    force_name = ship.force.name
                elseif player.force and player.force.name then
                    force_name = player.force.name
                end
                player.print(prefix .. tostring(force_name))
                return
            end
            -- fallback to log
            log(prefix .. "no valid player")
            return
        end
        -- server/console
        log(prefix .. "no player context")
    end)
end

return {
    initialize_mod = initialize_mod,
    on_load = on_load,
    on_entity_built = on_entity_built,
    on_entity_removed = on_entity_removed,
    on_object_destroyed = on_object_destroyed,
    on_surface_deleted = on_surface_deleted,
    on_chunk_generated = on_chunk_generated,
    sync_chunk_generated_handler = sync_chunk_generated_handler,
    should_enable_chunk_generated_handler = should_enable_chunk_generated_handler,
    reset_crystal_mined_bonuses = reset_crystal_mined_bonuses,
    on_runtime_mod_setting_changed = on_runtime_mod_setting_changed,
    find_safe_teleport_position = function(surface, preferred_pos)
        return find_safe_teleport_position(surface, preferred_pos)
    end,
    set_external_ship_post_warp_handler = set_external_ship_post_warp_handler,
    open_gas_leak_repair_gui = open_gas_leak_repair_gui,
    on_gas_leak_gui_click = on_gas_leak_gui_click,
    on_gas_leak_gui_closed = on_gas_leak_gui_closed,
    stop_all_gas_leaks = stop_all_gas_leaks
}