-- Made by ZepCannon
local util = require("util")

local function has_active_mod(mod_name)
    return script and script.active_mods and script.active_mods[mod_name] ~= nil
end
local HAS_SPACE_AGE = has_active_mod("space-age")

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
local DEFAULT_EVENTS = {
    laser_boss = {
        prototype = nil,
        -- WDM planet event parameters
        wdm_chance = 0.08,
        wdm_min_wap = 40,
        wdm_min_tech_progress = 0.1,
        wdm_no_repeat = true,
        wdm_requires_enemies = true,
        wdm_can_be_removed = false,
        wdm_difficulty_add = 0.01,
        wdm_alarm = true,
        -- Internal config
        action_name = "spawn_laser_boss_far",
        spawn_count = 1,
        spawn_opts = {
            min_dist = 70,
            max_dist = 250,
            spacing = 100,
            elite_chance = HAS_SPACE_AGE and 0.2 or 0
        },
        waves = { min = 1, max = 3 },
        wave_min_delay_seconds = 30,
        wave_max_delay_seconds = 120,
        tech_influence = 0.5,
        tech_tiers = nil
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
        ship_exclusion_radius = 60,
        enemy_bonus_per_crystal = 0.05 -- additive per mined crystal
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
    }
}

if has_active_mod("magnetic-storm") then
    DEFAULT_EVENTS.electromagnetic_storm = {
        -- WDM planet event parameters
        wdm_chance = 0.08,
        wdm_min_wap = 20,
        wdm_min_tech_progress = 0.1,
        wdm_no_repeat = true,
        wdm_requires_enemies = false,
        wdm_can_be_removed = false,
        wdm_difficulty_add = 0.05,
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
    if not settings.global then return true end
    local setting = settings.global["wdm-expansion-event-enable"]
    if setting then return setting.value end
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

local STORM_DISABLE_THRESHOLDS_BY_TYPE = {
    ["accumulator"] = 25,
    ["solar-panel"] = 45,
    ["generator"] = 55,
    ["fusion-generator"] = 65,
    ["electric-pole"] = 75
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

local function get_storm_disabled_records_for_surface(surface_index, create_if_missing)
    storage.storm_disabled_entities = storage.storm_disabled_entities or {}
    local records = storage.storm_disabled_entities[surface_index]
    if (not records) and create_if_missing then
        records = {}
        storage.storm_disabled_entities[surface_index] = records
    end
    return records
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
        name = entity.name,
        position = { x = pos.x, y = pos.y },
        unit_number = entity.unit_number
    }
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

local function apply_storm_disable_to_entity(entity, storm_value)
    if not (entity and entity.valid and entity.surface and entity.surface.valid) then return end

    local threshold = get_storm_disable_threshold(entity)
    if not threshold then return end

    local should_disable = storm_value >= threshold
    local surface_index = entity.surface.index
    local key = make_storm_entity_record_key(entity)

    if should_disable then
        local ok, changed = set_entity_disabled_by_storm(entity, true)
        if ok and changed then
            local records = get_storm_disabled_records_for_surface(surface_index, true)
            records[key] = make_storm_entity_record(entity)
        end
    else
        local records = get_storm_disabled_records_for_surface(surface_index, false)
        if records and records[key] then
            local ok = set_entity_disabled_by_storm(entity, false)
            if ok then
                records[key] = nil
                if not next(records) then
                    storage.storm_disabled_entities[surface_index] = nil
                end
            end
        end
    end
end

local function apply_storm_disable_on_surface(surface, storm_value)
    if not (surface and surface.valid) then return end
    local value = clamp(storm_value or 0, 0, 100)
    for _, entity_type in ipairs(STORM_DISABLE_ENTITY_TYPES) do
        local entities = surface.find_entities_filtered{ type = entity_type }
        for _, entity in ipairs(entities) do
            apply_storm_disable_to_entity(entity, value)
        end
    end
end

local function remove_storm_disabled_record_for_entity(entity)
    if not (entity and entity.valid and entity.surface and entity.surface.valid) then return end
    local records = get_storm_disabled_records_for_surface(entity.surface.index, false)
    if not records then return end

    records[make_storm_entity_record_key(entity)] = nil
    if not next(records) then
        storage.storm_disabled_entities[entity.surface.index] = nil
    end
end

local function restore_storm_disabled_on_surface(surface_index)
    if not (storage and storage.storm_disabled_entities) then return end
    local records = storage.storm_disabled_entities[surface_index]
    if not records then return end

    local surface = game.surfaces[surface_index]
    if surface and surface.valid then
        for _, record in pairs(records) do
            local found = surface.find_entities_filtered{
                name = record.name,
                position = record.position,
                radius = 0.5
            }
            for _, entity in ipairs(found) do
                if entity.valid and ((not record.unit_number) or entity.unit_number == record.unit_number) then
                    if entity.is_updatable then
                        entity.disabled_by_script = false
                    end
                    break
                end
            end
        end
    end

    storage.storm_disabled_entities[surface_index] = nil
end

local function restore_all_storm_disabled_entities()
    if not (storage and storage.storm_disabled_entities and next(storage.storm_disabled_entities)) then return end
    local indices = {}
    for surface_index in pairs(storage.storm_disabled_entities) do
        table.insert(indices, surface_index)
    end
    for _, surface_index in ipairs(indices) do
        restore_storm_disabled_on_surface(surface_index)
    end
end

local function apply_storm_disable_to_built_entity(entity)
    if not (entity and entity.valid and entity.surface and entity.surface.valid) then return end
    local storms = storage and storage.active_magnetic_storms
    if not storms then return end
    local storm_data = storms[entity.surface.index]
    if not storm_data then return end

    local storm_value = storm_data.storm_value
    if type(storm_value) ~= "number" then
        storm_value = get_magnetic_storm_value(entity.surface) or 0
    end

    apply_storm_disable_to_entity(entity, storm_value)
end

-- ============================================================
-- STORAGE (EVENTS)
-- ============================================================

local function init_event_storage()
    storage.events = storage.events or {}
    storage.scheduled_events = storage.scheduled_events or {}
    storage.active_earthquakes = storage.active_earthquakes or {}
    storage.lost_decks = storage.lost_decks or {}
    storage.active_magnetic_storms = storage.active_magnetic_storms or {}
    storage.storm_disabled_entities = storage.storm_disabled_entities or {}
    storage.crystal_overgrowth_active = storage.crystal_overgrowth_active or {}
    storage.crystal_overgrowth_blocked_zones = storage.crystal_overgrowth_blocked_zones or {}
    storage.crystal_bonus_overrides = storage.crystal_bonus_overrides or {}
    storage.enemy_melee_damage_bonus = storage.enemy_melee_damage_bonus or 0
    storage.enemy_biological_damage_bonus = storage.enemy_biological_damage_bonus or 0
end

local CRYSTAL_LOW_BONUS = 0.025
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

local function register_crystal_bonus_override(entity)
    if not (entity and entity.valid and entity.name == "crystal" and entity.surface and entity.surface.valid) then return end
    local ok, tile = pcall(function() return entity.surface.get_tile(entity.position) end)
    if not (ok and tile and tile.valid and tile.name and SPECIAL_CRYSTAL_BONUS_TILES[tile.name]) then return end
    storage.crystal_bonus_overrides = storage.crystal_bonus_overrides or {}
    local key = make_crystal_bonus_key(entity)
    if key then
        storage.crystal_bonus_overrides[key] = CRYSTAL_LOW_BONUS
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
-- DRUZHESTVENNYI URON (FRIENDLY FIRE) ДЛЯ СИЛ
-- ============================================================

local FRIENDLY_FIRE_FORCES = { "enemy", "pirate" }

local function apply_friendly_fire_setting()
    if not game or not game.forces then return end

    local disable = is_friendly_fire_disabled()

    for _, name in ipairs(FRIENDLY_FIRE_FORCES) do
        local force = game.forces[name]
        if force and force.valid and force.friendly_fire ~= nil then
            -- Если настройка включена – отключаем дружественный урон,
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
                    nil,                           -- must_have_on (nil = no requirement)
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

-- ============================================================
-- СПАВН СУЩНОСТЕЙ (helper)
-- ============================================================
--[[
local function spawn_pirate_base(ship, surface)
    if not (surface and surface.valid) then return end

    local force = game.forces.pirate or game.create_force("pirate")
    local pirate_pos = find_spawn_position_near_ship(ship, surface, 200, 400)
    if not pirate_pos then return end

    if ship and ship.force and ship.force.chart then
        ship.force.chart(surface, {{pirate_pos.x - 64, pirate_pos.y - 64}, {pirate_pos.x + 64, pirate_pos.y + 64}})
    end

    local pirate_tile = "refined-hazard-concrete-left"
    local radius = 16

    local tiles = {}
    for x = -radius, radius do
        for y = -radius, radius do
            table.insert(tiles, { name = pirate_tile, position = { pirate_pos.x + x, pirate_pos.y + y } })
        end
    end
    surface.set_tiles(tiles)

    local terminal = surface.create_entity{
        name = "wdm_terminal-2",
        position = pirate_pos,
        force = force
    }

    local turrets = {
        "wdm_pirate_gun-turret",
        "wdm_pirate_rocket-turret",
        "wdm_pirate_laser-turret"
    }
    for i = 1, 6 do
        local tpos = { x = pirate_pos.x + math.random(-10, 10), y = pirate_pos.y + math.random(-10, 10) }
        local turret = surface.create_entity{ name = turrets[math.random(#turrets)], position = tpos, force = force }
        if turret and turret.valid then
            if turret.name == "wdm_pirate_gun-turret" then turret.insert({ name = "piercing-rounds-magazine", count = 10 }) end
            if turret.name == "wdm_pirate_rocket-turret" then turret.insert({ name = "rocket", count = 5 }) end
            if turret.name == "wdm_pirate_laser-turret" then turret.energy = 500000 end
        end
    end

    for i = 1, 4 + math.random(3) do
        surface.create_entity{
            name = math.random() < 0.5 and "defender" or "destroyer",
            position = { pirate_pos.x + math.random(-8, 8), pirate_pos.y + math.random(-8, 8) },
            force = force
        }
    end

    rendering.draw_sprite{
        sprite = "space_pirate",
        x_scale = 0.7, y_scale = 0.7,
        target = { position = { pirate_pos.x, pirate_pos.y - 2 } },
        surface = surface
    }
    game.print({"pirate_base",pirate_pos.gps_tag})
    debug("[WDM Boss Expansion] ☠ Пираты построили временный лагерь на поверхности " .. surface.name)
    surface.play_sound{ path = "mf_sound_siren", volume_modifier = 0.8 }
end
]]
local function spawn_laser_boss_far_entity(ship, surface, prototype, count, opts)
    if not (surface and surface.valid) then return end
    prototype = prototype or "kj_electric_laser_t1"
    count = (count and count > 0) and count or 1
    opts = opts or {}

    local base_pos = (ship and ship.position) or { x = 0, y = 0 }

    for i = 1, count do
        local spawn_prototype = prototype
        local elite_chance = HAS_SPACE_AGE and (opts.elite_chance or 0) or 0
        local elite_prototype = prototype .. "_tesla"
        if elite_chance > 0 and math.random() < elite_chance and prototypes.entity[elite_prototype] then
            spawn_prototype = elite_prototype
        end

        local min_dist = opts.min_dist or 100
        local max_dist = opts.max_dist or 200
        local radial_offset = (i - 1) * (opts.spacing or 60)
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
            apply_turret_delay(boss, 10)
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
local teleport_player_to_available_deck
local find_safe_teleport_position
local spawn_crystals
local ensure_crystal_tick
local collect_ship_floor_surfaces_for_force

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
        schedule_event_for_tick(event_name, ship_stub, surface, delay_ticks, meta)
        return
    end

    -- Для других событий (earthquake) выполняем сразу
    local ok, err = pcall(action, surface, ev, ship_stub, meta)
    if not ok then
        debug("Error executing action for event '" .. event_name .. "': " .. tostring(err))
    end
end

-- ACTION: Спавн лазерного босса (использует unified threat level)
ACTIONS.spawn_laser_boss_far = function(surface, ev, ship_stub, meta)
    local base_count = ev.spawn_count or ev.count or 1
    local opts = ev.spawn_opts or {}

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

    if not set_magnetic_storm_value(surface, applied_value) then
        debug("electromagnetic_storm: failed to set magnetic-storm property on surface " .. tostring(surface.name))
        return false, nil, nil
    end

    storage.active_magnetic_storms = storage.active_magnetic_storms or {}
    storage.active_magnetic_storms[surface.index] = {
        end_tick = effective_end_tick,
        surface_name = surface.name,
        base_value = (existing and existing.base_value) or previous_value,
        storm_value = applied_value,
        silent = silent and true or nil
    }

    apply_storm_disable_on_surface(surface, applied_value)
    return true, applied_value, effective_end_tick
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
    local display_end_tick = end_tick

    -- use a large tick value so the storm never expires on its own
    local stored_end = math.huge

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
    storage.crystal_overgrowth_blocked_zones = storage.crystal_overgrowth_blocked_zones or {}
    local blocked_zone = nil
    if center then
        blocked_zone = {
            position = { x = center.x, y = center.y },
            radius = cfg.ship_exclusion_radius or DEFAULT_EVENTS.crystal_overgrowth.ship_exclusion_radius 
        }
    end
    storage.crystal_overgrowth_blocked_zones[surface.index] = blocked_zone
    game.print({ "wdm-expansion.crystal_overgrowth_started", surface.name })
    spawn_crystals(surface, cfg.initial_count or 8, center, blocked_zone, true)
    storage.crystal_overgrowth_active = storage.crystal_overgrowth_active or {}
    storage.crystal_overgrowth_active[surface.index] = true
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

-- ============================================================
-- EARTHQUAKE HELPERS
-- ============================================================

-- ACTION: Crystal overgrowth - spawns crystals and enables periodic growth
spawn_crystals = function(surface, count, center_pos, blocked_zone, announce_in_chat)
    if not (surface and surface.valid) then return end
    count = count or 4

    local function is_inside_blocked_zone(pos)
        if not (blocked_zone and blocked_zone.position and blocked_zone.radius and pos) then return false end
        return distance(pos, blocked_zone.position) < blocked_zone.radius
    end

    for i = 1, count do
        local pos
        if center_pos then
            if blocked_zone and blocked_zone.position and blocked_zone.radius then
                local angle = math.random() * math.pi * 2
                local min_dist = blocked_zone.radius + 6
                local max_dist = min_dist + 48
                local dist = min_dist + (math.random() * (max_dist - min_dist))
                pos = {
                    x = center_pos.x + math.cos(angle) * dist,
                    y = center_pos.y + math.sin(angle) * dist
                }
            else
                pos = { x = center_pos.x + math.random(-30, 30), y = center_pos.y + math.random(-30, 30) }
            end
        else
            pos = { x = math.random(-250, 250), y = math.random(-250, 250) }
        end

        if not is_inside_blocked_zone(pos) and surface.find_non_colliding_position then
            local safe = surface.find_non_colliding_position("crystal", pos, 16, 0.5, false)
            if safe and not is_inside_blocked_zone(safe) then
                pos = safe
            else
                pos = nil
            end
        end

        if pos and not is_inside_blocked_zone(pos) then
            local ok, crystal = pcall(function()
                return surface.create_entity{ name = "crystal", position = pos, force = game.forces.neutral }
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

local function crystal_growth_tick(event)
    if not (storage and storage.crystal_overgrowth_active and next(storage.crystal_overgrowth_active)) then
        script.on_nth_tick(storage.crystal_growth_interval or 3600, nil)
        return
    end
    local ev = storage.events and storage.events.crystal_overgrowth or DEFAULT_EVENTS.crystal_overgrowth
    local growth = (ev and ev.growth_count) or 2
    for surface_index, _ in pairs(storage.crystal_overgrowth_active) do
        local surface = game.surfaces[surface_index]
        if surface and surface.valid then
            local blocked_zone = storage.crystal_overgrowth_blocked_zones and storage.crystal_overgrowth_blocked_zones[surface_index]
            spawn_crystals(surface, growth, nil, blocked_zone)
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

-- Apply melee and biological buffs when crystal is mined
local function on_crystal_mined(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end
    if entity.name ~= "crystal" then return end

    local ev = storage.events and storage.events.crystal_overgrowth or DEFAULT_EVENTS.crystal_overgrowth
    local bonus = (ev and ev.enemy_bonus_per_crystal) or 0.03
    local bonus_override = take_crystal_bonus_override(entity)
    if type(bonus_override) == "number" then
        bonus = bonus_override
    end
    storage.enemy_melee_damage_bonus = (storage.enemy_melee_damage_bonus or 0) + bonus
    storage.enemy_biological_damage_bonus = (storage.enemy_biological_damage_bonus or 0) + bonus

    pcall(function()
        local f = game.forces and game.forces["enemy"]
        if not (f and f.valid) then return end
        if f.set_ammo_damage_modifier then pcall(function() f.set_ammo_damage_modifier("melee", storage.enemy_melee_damage_bonus) end) end
        if f.set_ammo_damage_modifier then pcall(function() f.set_ammo_damage_modifier("biological", storage.enemy_biological_damage_bonus) end) end
    end)
    game.print({"wdm-expansion.crystal_mined", storage.enemy_melee_damage_bonus * 100})
    debug("Crystal mined, enemy melee bonus is now " .. tostring(storage.enemy_melee_damage_bonus)
        .. ", biological bonus is now " .. tostring(storage.enemy_biological_damage_bonus))
end

local function apply_enemy_damage_bonuses()
    pcall(function()
        local f = game.forces and game.forces["enemy"]
        if not (f and f.valid) then return end
        if f.set_ammo_damage_modifier then pcall(function() f.set_ammo_damage_modifier("melee", storage.enemy_melee_damage_bonus) end) end
        if f.set_ammo_damage_modifier then pcall(function() f.set_ammo_damage_modifier("biological", storage.enemy_biological_damage_bonus) end) end
    end)
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
    -- Если нет ни активных землетрясений, ни потерянных уровней, отключаем on_nth_tick
    if (not storage.active_earthquakes or not next(storage.active_earthquakes))
        and (not storage.lost_decks or not next(storage.lost_decks))
        and (not storage.active_magnetic_storms or not next(storage.active_magnetic_storms)) then
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
        -- storms are now infinite, expire only if surface vanishes
        local s = game.surfaces[surface_index]
        if not (s and s.valid) then
            table.insert(storm_surfaces_to_end, surface_index)
        end
    end
    for _, si in ipairs(storm_surfaces_to_end) do
        end_magnetic_storm(si)
    end
    
    -- Если после удаления землетрясений и восстановления уровней их не осталось, отключаем on_nth_tick
    if not next(storage.active_earthquakes)
        and not next(storage.lost_decks or {}) then
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
    -- storms no longer control the tick handler; they only end on warp/invalid surface
    
    -- Включаем on_tick только если есть scheduled events
    if has_scheduled then
        script.on_event(defines.events.on_tick, process_scheduled_events)
    else
        script.on_event(defines.events.on_tick, nil)
    end
    
    -- on_nth_tick нужен теперь только для землетрясений/потерянных уровней
    if has_earthquakes or has_lost then
        script.on_nth_tick(60, check_earthquakes)
    else
        script.on_nth_tick(60, nil)
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

    local old_melee_bonus = storage.enemy_melee_damage_bonus or 0
    local old_biological_bonus = storage.enemy_biological_damage_bonus or 0
    local new_melee_bonus = old_melee_bonus
    local new_biological_bonus = old_biological_bonus

    if old_melee_bonus > 0 then
        new_melee_bonus = math.max(0, old_melee_bonus - 0.005)
    end
    if old_biological_bonus > 0 then
        new_biological_bonus = math.max(0, old_biological_bonus - 0.005)
    end

    if new_melee_bonus ~= old_melee_bonus or new_biological_bonus ~= old_biological_bonus then
        storage.enemy_melee_damage_bonus = new_melee_bonus
        storage.enemy_biological_damage_bonus = new_biological_bonus
        apply_enemy_damage_bonuses()
        debug("Ship warp reduced enemy bonuses: melee "
            .. string.format("%.3f", old_melee_bonus) .. " -> " .. string.format("%.3f", new_melee_bonus)
            .. ", biological "
            .. string.format("%.3f", old_biological_bonus) .. " -> " .. string.format("%.3f", new_biological_bonus))
    else
        debug("Ship warp left enemy bonuses unchanged: melee="
            .. string.format("%.3f", old_melee_bonus)
            .. ", biological=" .. string.format("%.3f", old_biological_bonus))
    end

    if storage and storage.crystal_overgrowth_active and next(storage.crystal_overgrowth_active) then
        stop_all_crystal_growth()
        debug("All active crystal growth ended due to ship warp")
    end
    if has_active_mod("magnetic-storm") then
        -- stop any active storms immediately when a warp happens
        end_all_magnetic_storms()
        debug("All active magnetic storms ended due to ship warp")

        -- when a ship warps we may also have left a surface with storm‑disabled entities,
        -- or arrived somewhere; restore them just in case
        if event and event.destination_surface and event.destination_surface.valid then
            restore_storm_disabled_on_surface(event.destination_surface.index)
            debug("Called restore_storm_disabled_on_surface for surface " .. tostring(event.destination_surface.name))
        end
        -- also clear any leftover records on all surfaces (quiet no-op if none)
        restore_all_storm_disabled_entities()
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

        -- Отменяем регистрацию обработчиков WDM-событий
        if remote.interfaces["WDM"] then
            local ok, id
            ok, id = pcall(function() return remote.call("WDM", "get_on_custom_planet_event") end)
            if ok and id then script.on_event(id, nil) end
            ok, id = pcall(function() return remote.call("WDM", "get_on_ship_warping") end)
            if ok and id then script.on_event(id, nil) end
        end
        debug("WDM Boss Expansion mod DISABLED - event handlers unregistered")
    end

    -- Применяем настройку дружественного урона независимо от включенности
    -- основных эвентов мода, т.к. она отвечает только за поведение сил.
    apply_friendly_fire_setting()
end

local function initialize_mod()
    init_event_storage()
    sync_default_events()
    register_event_handlers()
    if storage.crystal_overgrowth_active and next(storage.crystal_overgrowth_active) then
        ensure_crystal_tick()
    end

    if storage.active_magnetic_storms and next(storage.active_magnetic_storms) then
        for surface_index, storm_data in pairs(storage.active_magnetic_storms) do
            local surface = game.surfaces[surface_index]
            if surface and surface.valid then
                local storm_value = storm_data and storm_data.storm_value
                if type(storm_value) ~= "number" then
                    storm_value = get_magnetic_storm_value(surface) or 0
                end
                apply_storm_disable_on_surface(surface, storm_value)
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
    apply_storm_disable_to_built_entity(entity)
end

local function on_entity_removed(event)
    on_crystal_mined(event)
    remove_storm_disabled_record_for_entity(event.entity)
end

local function on_load()
    register_event_handlers()
    if storage.crystal_overgrowth_active and next(storage.crystal_overgrowth_active) then
        ensure_crystal_tick()
    end
end

return {
    initialize_mod = initialize_mod,
    on_load = on_load,
    on_entity_built = on_entity_built,
    on_entity_removed = on_entity_removed,
    on_runtime_mod_setting_changed = on_runtime_mod_setting_changed,
    find_safe_teleport_position = function(surface, preferred_pos)
        return find_safe_teleport_position(surface, preferred_pos)
    end
}
