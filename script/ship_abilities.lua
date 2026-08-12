local ship_abilities = {}
local function is_debug_enabled()
    if not settings.global then return false end
    local setting = settings.global["wdm-expansion-debug"]
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

-- Плитки, на которых разрешено ставить консоль
local ALLOWED_CONSOLE_TILES = {
    ["orange-refined-concrete"] = true,
    ["yellow-refined-concrete"] = true,
    ["cyan-refined-concrete"] = true,
    ["purple-refined-concrete"] = true,
    ["black-refined-concrete"] = true,
    ["green-refined-concrete"] = true,
    ["blue-refined-concrete"] = true
}

local WDM_TERMINAL_NAMES = {
    "wdm_terminal-1", "wdm_terminal-2", "wdm_terminal-3", "wdm_terminal-4",
    "wdm_terminal-5", "wdm_terminal-6", "wdm_terminal-7", "wdm_terminal-8"
}

-- Конфигурация способностей
local ABILITIES_CONFIG = {
    ["cryo_freeze"] = {
        name = "cryo_freeze",
        localised_name = {"wdm-expansion.ship-ability-cryo-freeze"},
        localised_desc = {"wdm-expansion.ship-ability-cryo-freeze-description"},
        cost_fluid = 100,
        duration_ticks = 10 * 60,
        cooldown_ticks = 2 * 60 * 60,
        tech_required = "wdm-ship-ability-cryo-freeze",
        max_uses_per_warp = 2
    },
    ["reactor_boost"] = {
        name = "reactor_boost",
        localised_name = {"wdm-expansion.ship-ability-reactor-boost"},
        localised_desc = {"wdm-expansion.ship-ability-reactor-boost-description"},
        cost_fluid = 1500,
        cooldown_ticks = 15 * 60 * 60,
        tech_required = "wdm-ship-ability-reactor-boost",
        max_uses_per_warp = 2
    },
    ["ammo_distributor"] = {
        name = "ammo_distributor",
        localised_name = {"wdm-expansion.ship-ability-ammo-distributor"},
        localised_desc = {"wdm-expansion.ship-ability-ammo-distributor-description"},
        cost_fluid = 800,
        cooldown_ticks = 5 * 60 * 60,
        tech_required = "wdm-ship-ability-ammo-distributor",
        max_uses_per_warp = 3
    },
    ["resource_collector"] = {
        name = "resource_collector",
        localised_name = {"wdm-expansion.ship-ability-resource-collector"},
        localised_desc = {"wdm-expansion.ship-ability-resource-collector-description"},
        cost_fluid = 400,
        cooldown_ticks = 5 * 60 * 60,
        tech_required = "wdm-ship-ability-resource-collector",
        max_uses_per_warp = 3
    },
    ["cloak"] = {
        name = "cloak",
        localised_name = {"wdm-expansion.ship-ability-cloak"},
        localised_desc = {"wdm-expansion.ship-ability-cloak-description"},
        cost_fluid = 3000,
        duration_ticks = 20 * 60,
        cooldown_ticks = 10 * 60 * 60,
        tech_required = "wdm-ship-ability-cloak",
        max_uses_per_warp = 1
    },
--    ["waste_recycler"] = {
--        name = "waste_recycler",
--        localised_name = {"wdm-expansion.ship-ability-waste-recycler"},
--        localised_desc = {"wdm-expansion.ship-ability-waste-recycler-description"},
--        cost_fluid = 500,
--        cooldown_ticks = 3 * 60 * 60,
--        tech_required = "wdm-ship-ability-waste-recycler"
--    }
}

local AMMO_TYPES = {
    "firearm-magazine", "piercing-rounds-magazine", "uranium-rounds-magazine"
}

local function init_storage()
    storage.ship_abilities = storage.ship_abilities or {}
    storage.ship_abilities.force_states = storage.ship_abilities.force_states or {}
    storage.ship_abilities.active_effects = storage.ship_abilities.active_effects or {}
    storage.ship_abilities.player_chest_selection_mode = storage.ship_abilities.player_chest_selection_mode or {}
    
    -- Регистрация storage-tank для warponium fluid
    storage.ship_abilities.fluid_tanks = storage.ship_abilities.fluid_tanks or {} -- [unit_number] = {surface_index, position}
    storage.ship_abilities.fluid_tank_destroy_registrations = storage.ship_abilities.fluid_tank_destroy_registrations or {
        by_registration = {}, -- [registration_number] = unit_number
        by_unit_number = {}   -- [unit_number] = registration_number
    }
end

-- runtime cache: [unit_number] = entity (не сохраняется)
local fluid_tank_cache = {}

local function clear_fluid_tank_destroy_registration(unit_number)
    local registrations = storage.ship_abilities.fluid_tank_destroy_registrations
    if not (registrations and unit_number) then return end
    local registration_number = registrations.by_unit_number[unit_number]
    if registration_number then
        registrations.by_unit_number[unit_number] = nil
        registrations.by_registration[registration_number] = nil
    end
end

local function register_fluid_tank_for_destroy_event(entity)
    if not (entity and entity.valid and entity.unit_number) then return end
    local registrations = storage.ship_abilities.fluid_tank_destroy_registrations
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

local function find_entity_for_tank_record(record)
    if not record then return nil end
    local surface = record.surface_index and game.surfaces[record.surface_index]
    if not (surface and surface.valid and record.position) then return nil end
    local found = surface.find_entities_filtered{
        name = "warponium-storage-tank",
        position = record.position,
        radius = 0.5,
        limit = 1
    }
    return found and found[1] or nil
end

local function rebuild_fluid_tank_destroy_registrations()
    local registrations = storage.ship_abilities.fluid_tank_destroy_registrations
    registrations.by_registration = {}
    registrations.by_unit_number = {}
    
    for unit_number, record in pairs(storage.ship_abilities.fluid_tanks) do
        local entity = fluid_tank_cache[unit_number]
        if not (entity and entity.valid) then
            entity = find_entity_for_tank_record(record)
            fluid_tank_cache[unit_number] = entity
        end
        if entity and entity.valid then
            register_fluid_tank_for_destroy_event(entity)
        else
            clear_fluid_tank_destroy_registration(unit_number)
            storage.ship_abilities.fluid_tanks[unit_number] = nil
            fluid_tank_cache[unit_number] = nil
        end
    end
end

local function remove_fluid_tank_by_unit_number(unit_number)
    if not unit_number then return end
    storage.ship_abilities.fluid_tanks[unit_number] = nil
    fluid_tank_cache[unit_number] = nil
    clear_fluid_tank_destroy_registration(unit_number)
end

local function on_fluid_tank_built(event)
    -- 1. Сначала берем сущность (быстрая операция Lua)
    local entity = event.entity or event.created_entity
    if not (entity and entity.valid) then return end
    if entity.name ~= "warponium-storage-tank" then return end
    if entity.type ~= "storage-tank" then return end
    init_storage()
    storage.ship_abilities.fluid_tanks[entity.unit_number] = {
        surface_index = entity.surface.index,
        position = entity.position 
    }
    fluid_tank_cache[entity.unit_number] = entity
    register_fluid_tank_for_destroy_event(entity)
end


local function on_fluid_tank_removed(event)
    local entity = event.entity
    if not entity then return end
    if entity.name ~= "warponium-storage-tank" then return end
    remove_fluid_tank_by_unit_number(entity.unit_number)
end

function ship_abilities.on_entity_built(event)
    on_fluid_tank_built(event)
    
    -- Проверяем, не построили ли консоль способностей на ship_interior
    local entity = event.entity or event.created_entity
    if not (entity and entity.valid) then return end
    if entity.name ~= "wdm-ship-abilities-console" then return end
    if not string.match(entity.surface.name, "^ship_interior") then return end
    
    -- Уничтожаем консоль
    entity.destroy()
    
    -- Возвращаем предмет игроку
    local player = event.player_index and game.get_player(event.player_index)
    if player and player.valid then
        if player.character and player.character.valid then
            local inserted = player.character.insert{name = "wdm-ship-abilities-console", count = 1}
            if inserted == 0 then
                -- Если в инвентаре нет места, выбрасываем на землю
                player.surface.spill_item_stack(player.position, {name = "wdm-ship-abilities-console", count = 1}, true)
            end
        else
            -- Если нет персонажа, выбрасываем на землю
            player.surface.spill_item_stack(player.position, {name = "wdm-ship-abilities-console", count = 1}, true)
        end
        player.print({"wdm-expansion.ship-abilities-console-no-ship-interior"})
    else
        -- Если игрок неизвестен (робот), выбрасываем на место постройки
        if entity and entity.valid then
            entity.surface.spill_item_stack(entity.position, {name = "wdm-ship-abilities-console", count = 1}, true)
        end
    end
end

function ship_abilities.on_entity_removed(event)
    on_fluid_tank_removed(event)
end

function ship_abilities.on_object_destroyed(event)
    init_storage()
    local registrations = storage.ship_abilities.fluid_tank_destroy_registrations
    if not registrations then return end
    local unit_number = registrations.by_registration[event.registration_number] or event.useful_id
    if not unit_number or not storage.ship_abilities.fluid_tanks[unit_number] then return end
    remove_fluid_tank_by_unit_number(unit_number)
end

local function get_force_state(force_name)
    if not storage.ship_abilities.force_states[force_name] then
        storage.ship_abilities.force_states[force_name] = {
            ability_cooldowns = {},
            ability_uses = {}, -- [ability_name] = uses_count (сбрасывается при варпе)
            cloaked = false,
            frozen_players = {},
            console_unit_number = nil,
            ship_surfaces = {},
            resource_collector_target = nil,
            waste_recycler_item = nil
        }
    end
    return storage.ship_abilities.force_states[force_name]
end

local function find_entity_for_target(record)
    if not record then return nil end
    
    local surface = record.surface_index and game.surfaces[record.surface_index]
    if not (surface and surface.valid and record.name and record.position) then 
        return nil 
    end
    
    local found = surface.find_entities_filtered{
        name = record.name,
        position = record.position,
        radius = 0.5,
        type = {"container", "logistic-container"},
        limit = 1
    }
    
    return found and found[1] or nil
end

local function is_ability_unlocked(force, ability_name)
    if not force or not force.valid or not ability_name then return false end
    local tech_required = ABILITIES_CONFIG[ability_name].tech_required
    if not tech_required then return true end
    local tech = force.technologies[tech_required]
    return tech and tech.researched or false
end

local function get_ability_cooldown_remaining(force_name, ability_name)
    local state = get_force_state(force_name)
    local cooldown = state.ability_cooldowns[ability_name] or 0
    return math.max(0, cooldown - game.tick)
end

local function has_warponium_fluid(surface, amount)
    if not (surface and surface.valid) then return false end
    
    local surface_index = surface.index
    local total_fluid = 0
    
    for unit_number, record in pairs(storage.ship_abilities.fluid_tanks) do
        if record.surface_index == surface_index then
            local tank = fluid_tank_cache[unit_number]
            if not (tank and tank.valid) then
                tank = find_entity_for_tank_record(record)
                fluid_tank_cache[unit_number] = tank
            end
            if tank and tank.valid then
                local fluids = tank.get_fluid_contents()
                if fluids then
                    local fluid_amount = fluids["warponium-fluid"] or 0
                    total_fluid = total_fluid + fluid_amount
                end
            else
                -- Tank lost, clean up
                remove_fluid_tank_by_unit_number(unit_number)
            end
        end
    end
    
    return total_fluid >= amount
end

local function consume_warponium_fluid(surface, amount)
    if not (surface and surface.valid and amount > 0) then return false end
    
    local surface_index = surface.index
    
    for unit_number, record in pairs(storage.ship_abilities.fluid_tanks) do
        if record.surface_index == surface_index then
            local tank = fluid_tank_cache[unit_number]
            if not (tank and tank.valid) then
                tank = find_entity_for_tank_record(record)
                fluid_tank_cache[unit_number] = tank
            end
            if tank and tank.valid then --compabity for old version
                local removed
                local is_version_2 = (script.active_mods["base"] and script.active_mods["base"] >= "2.1.7")
                if is_version_2 and tank.fluidbox then
                    local extracted = tank.fluidbox.extract_fluid(amount, 1)
                    removed = extracted and extracted.amount or 0
                else
                    removed = tank.remove_fluid({name = "warponium-fluid", amount = amount})
                end
                
                if removed >= amount then return true end
                amount = amount - removed
            else
                remove_fluid_tank_by_unit_number(unit_number)
            end
        end
    end
    return amount <= 0
end


local current_ticker_interval = nil

local function update_ticker_state()
    if not game then return end
    
    local need_ticker = false
    local min_remaining = nil
    
    if storage.ship_abilities and storage.ship_abilities.force_states then
        local tick = game.tick
        for _, state in pairs(storage.ship_abilities.force_states) do
            if state.cloaked and state.cloak_end_tick then
                need_ticker = true
                local remaining = state.cloak_end_tick - tick
                if remaining > 0 then
                    min_remaining = min_remaining and math.min(min_remaining, remaining) or remaining
                end
            end
            if state.cryo_freeze_end_tick then
                need_ticker = true
                local remaining = state.cryo_freeze_end_tick - tick
                if remaining > 0 then
                    min_remaining = min_remaining and math.min(min_remaining, remaining) or remaining
                end
            end
        end
    end
    
    if need_ticker and min_remaining then
        local interval = math.max(1, min_remaining + 1)
        if current_ticker_interval then
            script.on_nth_tick(current_ticker_interval, nil)
        end
        script.on_nth_tick(interval, ship_abilities.on_tick)
        current_ticker_interval = interval
        debug("[ship_abilities] Dynamic ticker: turned ON (" .. interval .. " ticks step, " .. min_remaining .. " ticks remaining)")
    elseif need_ticker then
        if current_ticker_interval then
            script.on_nth_tick(current_ticker_interval, nil)
        end
        script.on_nth_tick(1, ship_abilities.on_tick)
        current_ticker_interval = 1
        debug("[ship_abilities] Dynamic ticker: turned ON (1 tick step, overdue)")
    else
        if current_ticker_interval then
            script.on_nth_tick(current_ticker_interval, nil)
            current_ticker_interval = nil
            debug("[ship_abilities] Dynamic ticker: turned OFF")
        end
    end
end

local CLOAK_CEASE_FIRE_FORCES = {"enemy", "pirate"}

local function activate_cloak(force, all_surfaces)
    if not (force and force.valid) then return false end
    
    local state = get_force_state(force.name)
    state.cloaked = true
    state.cloak_end_tick = game.tick + ABILITIES_CONFIG.cloak.duration_ticks
    
    local previous_cease_fire = {}
    local active_forces = 0
    
    for _, other_force_name in ipairs(CLOAK_CEASE_FIRE_FORCES) do
        local other_force = game.forces[other_force_name]
        if other_force and other_force.valid then
            previous_cease_fire[other_force_name] = force.get_cease_fire(other_force_name)
            force.set_cease_fire(other_force_name, true)
            other_force.set_cease_fire(force.name, true)
            active_forces = active_forces + 1
            debug("[ship_abilities] Cloak: cease fire with " .. other_force_name)
        end
    end
    
    state.cloak_previous_cease_fire = previous_cease_fire
    update_ticker_state()
    game.print({"wdm-expansion.cloak-activated", active_forces})
    return true
end

local function deactivate_cloak(force, surface)
    if not (force and force.valid) then return false end
    
    local state = get_force_state(force.name)
    state.cloaked = false
    state.cloak_end_tick = nil
    
    local previous = state.cloak_previous_cease_fire or {}
    local active_forces = 0
    
    for _, other_force_name in ipairs(CLOAK_CEASE_FIRE_FORCES) do
        local other_force = game.forces[other_force_name]
        if other_force and other_force.valid then
            local was_cease_fire = previous[other_force_name]
            if was_cease_fire ~= nil then
                force.set_cease_fire(other_force_name, was_cease_fire)
                other_force.set_cease_fire(force.name, was_cease_fire)
            else
                force.set_cease_fire(other_force_name, false)
                other_force.set_cease_fire(force.name, false)
            end
            active_forces = active_forces + 1
            debug("[ship_abilities] Cloak: restore cease fire with " .. other_force_name)
        end
    end
    
    state.cloak_previous_cease_fire = nil
    update_ticker_state()
    game.print({"wdm-expansion.cloak-deactivated", active_forces})
    return true
end

-- Вспомогательная: собрать турели и сундуки со всех переданных поверхностей
local function collect_turrets_and_chests(force, all_surfaces)
    local turrets = {}
    local chests = {}
    
    for _, s in pairs(all_surfaces) do
        if s and s.valid then
            local ts = s.find_entities_filtered{type = "ammo-turret", force = force}
            for _, t in pairs(ts) do table.insert(turrets, t) end
            
            local cs = s.find_entities_filtered{
                type = {"container", "logistic-container"},
                force = force
            }
            for _, c in pairs(cs) do table.insert(chests, c) end
        end
    end
    
    return turrets, chests
end

local function activate_ammo_distributor(force, all_surfaces)
    if not (force and force.valid) then return false end
    
    local turrets, chests = collect_turrets_and_chests(force, all_surfaces)
    
    if #turrets == 0 then
        debug("[ship_abilities] Ammo distributor: no turrets found")
        return true
    end
    
    if #chests == 0 then
        debug("[ship_abilities] Ammo distributor: no chests found")
        game.print({"wdm-expansion.ammo-distributor-no-chests"})
        return false
    end
    
    local restocked_count = 0
    
    -- Кешируем инвентари сундуков
    local chest_inventories = {}
    for i, chest in ipairs(chests) do
        if chest.valid then
            chest_inventories[i] = chest.get_inventory(defines.inventory.chest)
        end
    end
    
    for _, turret in pairs(turrets) do
        if turret.valid then
            local ammo_inv = turret.get_inventory(defines.inventory.turret_ammo)
            if ammo_inv and ammo_inv.is_empty() then
                local found_ammo = false
                
                for i, source_inv in pairs(chest_inventories) do
                    if source_inv and source_inv.valid then
                        for _, ammo_item in ipairs(AMMO_TYPES) do
                            local count = source_inv.get_item_count(ammo_item)
                            if count > 0 then
                                local to_move = math.min(count, 10)
                                source_inv.remove({name = ammo_item, count = to_move})
                                ammo_inv.insert({name = ammo_item, count = to_move})
                                restocked_count = restocked_count + 1
                                found_ammo = true
                                break
                            end
                        end
                        if found_ammo then break end
                    end
                end
            end
        end
    end
    
    game.print({"wdm-expansion.ammo-distributor-restocked", restocked_count})
    return true
end

local function activate_waste_recycler(force, all_surfaces)
    if not (force and force.valid) then return false end
    
    local state = get_force_state(force.name)
    local item_to_recycle = state.waste_recycler_item
    
    if not item_to_recycle or not item_to_recycle.name then
        debug("[ship_abilities] Waste recycler: no item selected by player")
        game.print({"wdm-expansion.waste-recycler-no-item-selected"})
        return false
    end
    
    local item_name = item_to_recycle.name
    if item_name == "scrap" then
        game.print({"wdm-expansion.waste-recycler-cannot-recycle"})
        return false
    end
    
    -- Собираем инвентари со ВСЕХ переданных поверхностей
    local all_inventories = {}
    local total_count = 0
    
    for _, s in pairs(all_surfaces) do
        if s and s.valid then
            local chests = s.find_entities_filtered{
                type = {"container", "logistic-container"},
                force = force
            }
            for _, chest in pairs(chests) do
                if chest.valid then
                    local inv = chest.get_inventory(defines.inventory.chest)
                    if inv then
                        table.insert(all_inventories, inv)
                        total_count = total_count + inv.get_item_count(item_name)
                    end
                end
            end
        end
    end
    
    if #all_inventories == 0 then
        game.print({"wdm-expansion.resource-collector-no-chests"})
        return false
    end
    
    local to_remove = math.min(total_count, 100)
    local removed_total = 0
    
    for _, inv in ipairs(all_inventories) do
        if to_remove <= 0 then break end
        local r = inv.remove({name = item_name, count = to_remove})
        to_remove = to_remove - r
        removed_total = removed_total + r
    end
    
    local scrap_earned = math.floor(removed_total / 100) * 20
    if scrap_earned > 0 then
        for _, inv in ipairs(all_inventories) do
            local inserted = inv.insert({name = "scrap", count = scrap_earned})
            scrap_earned = scrap_earned - inserted
            if scrap_earned <= 0 then break end
        end
    end
    
    if removed_total > 0 then
        game.print({"wdm-expansion.waste-recycler-converted", item_name, removed_total, math.floor(removed_total / 100) * 20})
    else
        game.print({"wdm-expansion.waste-recycler-no-items"})
    end
    return true
end

local function check_reactor_boost(force, all_surfaces)
    if not (force and force.valid and all_surfaces) then return false end
    for _, surface in pairs(all_surfaces) do
        if surface and surface.valid then
            local reactors = surface.find_entities_filtered({type = "reactor", force = force})
            if next(reactors) then return true end
        end
    end
    return false
end

local function check_ammo_distributor_turrets_and_ammo(force, all_surfaces)
    if not (force and force.valid and all_surfaces) then return false, false end
    local has_empty_turret = false
    local has_ammo = false
    
    for _, surface in pairs(all_surfaces) do
        if surface and surface.valid then
            if not has_empty_turret then
                local turrets = surface.find_entities_filtered({type = "ammo-turret", force = force})
                for _, t in pairs(turrets) do
                    if t.valid then
                        local ammo_inv = t.get_inventory(defines.inventory.turret_ammo)
                        if ammo_inv and ammo_inv.is_empty() then
                            has_empty_turret = true
                            break
                        end
                    end
                end
            end
            if not has_ammo then
                local chests = surface.find_entities_filtered({
                    type = {"container", "logistic-container"},
                    force = force
                })
                for _, chest in pairs(chests) do
                    if chest.valid then
                        local inv = chest.get_inventory(defines.inventory.chest)
                        if inv and inv.valid then
                            for _, ammo_type in ipairs(AMMO_TYPES) do
                                if inv.get_item_count(ammo_type) > 0 then
                                    has_ammo = true
                                    break
                                end
                            end
                        end
                        if has_ammo then break end
                    end
                end
            end
        end
    end
    
    return has_empty_turret, has_ammo
end

local function check_resource_collector_items(force, all_surfaces)
    if not all_surfaces then return false end
    for _, surface in pairs(all_surfaces) do
        if surface and surface.valid then
            local items = surface.find_entities_filtered({type = "item-entity"})
            if next(items) then return true end
        end
    end
    return false
end

local function check_cryo_freeze_players(force, all_surfaces)
    if not (force and force.valid and all_surfaces) then return false end
    for _, player in pairs(game.connected_players) do
        if player.valid and player.force.name == force.name then
            if all_surfaces[player.surface.name] then
                if player.character and player.character.valid then
                    return true
                end
            end
        end
    end
    return false
end

local function check_waste_recycler_has_items(force, all_surfaces, item_name)
    if not (force and force.valid and all_surfaces and item_name) then return false end
    for _, surface in pairs(all_surfaces) do
        if surface and surface.valid then
            local chests = surface.find_entities_filtered({
                type = {"container", "logistic-container"},
                force = force
            })
            for _, chest in pairs(chests) do
                if chest.valid then
                    local inv = chest.get_inventory(defines.inventory.chest)
                    if inv and inv.valid and inv.get_item_count(item_name) > 0 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function activate_reactor_boost(force, all_surfaces)
    if not (force and force.valid and all_surfaces) then return false end
    
    local total_boosted = 0
    
    for _, surface in pairs(all_surfaces) do
        if surface and surface.valid then
            local reactors = surface.find_entities_filtered({type = "reactor", force = force})
            for _, reactor in pairs(reactors) do
                if reactor.valid then
                    reactor.temperature = 800
                    total_boosted = total_boosted + 1
                end
            end
        end
    end
    
    if total_boosted > 0 then
        game.print({"wdm-expansion.reactor-boost-activated", total_boosted})
        return true
    end
    
    return false
end

local function activate_cryo_freeze(force, all_surfaces)
    if not (force and force.valid and all_surfaces) then return false end
    
    local state = get_force_state(force.name)
    state.cryo_freeze_end_tick = game.tick + ABILITIES_CONFIG.cryo_freeze.duration_ticks
    state.frozen_players = state.frozen_players or {}
    
    local frozen_count = 0
    for _, player in pairs(game.connected_players) do
        if player.valid and player.force.name == force.name and player.character and player.character.valid then
            if all_surfaces[player.surface.name] then
                state.frozen_players[tostring(player.index)] = true --compability for old verion
                local is_version_2 = (script.active_mods["base"] and script.active_mods["base"] >= "2.1.7")
                if is_version_2 then
                    player.character.disabled_by_script = true
                else
                    player.character.active = false
                end
                player.character.destructible = false
                frozen_count = frozen_count + 1
                debug("[ship_abilities] Frozen player: " .. player.name)
            end
        end
    end
    
    update_ticker_state()
    game.print({"wdm-expansion.cryo-freeze-activated", frozen_count})
    return true
end

local function deactivate_cryo_freeze(force_name)
    local state = get_force_state(force_name)
    
    for player_key, _ in pairs(state.frozen_players or {}) do
        local player_index = tonumber(player_key)
        local player = game.get_player(player_index)
        if player and player.valid and player.character and player.character.valid then
            local is_version_2 = (script.active_mods["base"] and script.active_mods["base"] >= "2.1.7") --compability for old version
            if is_version_2 then
                player.character.disabled_by_script = false
            else
                player.character.active = true
            end
            player.character.destructible = true
            debug("[ship_abilities] Unfrozen player: " .. player.name)
        end
    end
    
    state.frozen_players = {}
    state.cryo_freeze_end_tick = nil 
    update_ticker_state()
    game.print({"wdm-expansion.cryo-freeze-deactivated"})
end

local function has_frozen_players(state)
    if not state.frozen_players then return false end
    for _, _ in pairs(state.frozen_players) do return true end
    return false
end

-- Функция resource_collector (собирает со всех переданных поверхностей)
local function activate_resource_collector(force, all_surfaces)
    if not (force and force.valid and all_surfaces) then return false end
    
    local state = get_force_state(force.name)
    local total_collected = 0
    
    for _, surface in pairs(all_surfaces) do
        if not (surface and surface.valid) then goto continue end
        
        local items = surface.find_entities_filtered({type = "item-entity"})
        if #items == 0 then goto continue end
        
        local target_chest = nil
        if state.resource_collector_target then
            target_chest = find_entity_for_target(state.resource_collector_target)
        end
        
        if target_chest and target_chest.valid then
            local inv = target_chest.get_inventory(defines.inventory.chest)
            if inv then
                for _, item in pairs(items) do
                    if item.valid and item.stack then
                        local inserted = inv.insert(item.stack)
                        if inserted > 0 then
                            if item.stack.count > inserted then
                                item.stack.count = item.stack.count - inserted
                            else
                                item.destroy()
                            end
                            total_collected = total_collected + inserted
                        end
                    end
                end
            end
        else
            local chests = surface.find_entities_filtered({
                type = {"container", "logistic-container"},
                force = force
            })
            
            for _, item in pairs(items) do
                if item.valid and item.stack then
                    for _, chest in pairs(chests) do
                        if chest and chest.valid then
                            local inv = chest.get_inventory(defines.inventory.chest)
                            if inv then
                                local inserted = inv.insert(item.stack)
                                if inserted > 0 then
                                    if item.stack.count > inserted then
                                        item.stack.count = item.stack.count - inserted
                                    else
                                        item.destroy()
                                    end
                                    total_collected = total_collected + inserted
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        
        ::continue::
    end
    
    if total_collected > 0 then
        game.print({"wdm-expansion.resource-collector-collected", total_collected})
        return true
    end
    
    return false
end

function ship_abilities.on_ship_post_warp(event)
    if not event then 
        debug("on_ship_post_warp: event is nil")
        return 
    end
    
    debug("[ship_abilities] on_ship_post_warp called")
    
    local ship = event.ship
    if not ship or not ship.force then 
        debug("[ship_abilities] on_ship_post_warp: no ship or force")
        return 
    end
    
    local force = game.forces[ship.force_name] or ship.force
    if force and force.valid then
        local state = get_force_state(force.name)
        
        -- Деактивируем временные способности ДО смены поверхностей
        if has_frozen_players(state) then
            deactivate_cryo_freeze(force.name)
        end
        
        if state.cloaked then
            deactivate_cloak(force)
        end
        
        state.ability_cooldowns = {}
        state.ability_uses = {} -- Сброс использований при варпе
        
        -- Перестраиваем регистрации storage-tank
        rebuild_fluid_tank_destroy_registrations()
        
        debug("[ship_abilities] Processing warp for force: " .. force.name)
        
        state.ship_surfaces = {}
        -- actual_surface из ship (event.ship.actual_surface)
        if ship.actual_surface and ship.actual_surface.valid then
            table.insert(state.ship_surfaces, ship.actual_surface)
            debug("[ship_abilities] Added actual_surface: " .. ship.actual_surface.name)
        end
        -- surfaces из ship (event.ship.surfaces) - массив строк (имён поверхностей) из extract_ship_data
        -- Добавляем только interior
        if ship.surfaces then
            for i, surface_ref in pairs(ship.surfaces) do
                local surface
                if type(surface_ref) == "string" then
                    surface = game.surfaces[surface_ref]
                else
                    surface = surface_ref
                end
                if surface and surface.valid and string.match(surface.name, "^ship_interior") then
                    table.insert(state.ship_surfaces, surface)
                    debug("[ship_abilities] Added interior surface #" .. i .. ": " .. surface.name)
                end
            end
        end
        
        debug("[ship_abilities] Total ship surfaces: " .. #state.ship_surfaces)
    else
        debug("[ship_abilities] on_ship_post_warp: force not valid")
    end
end

function ship_abilities.on_tick(event)
    if not storage.ship_abilities or not storage.ship_abilities.force_states then return end
    
    local tick = game.tick
    
    for force_name, state in pairs(storage.ship_abilities.force_states) do
        if state.cloaked and state.cloak_end_tick and tick >= state.cloak_end_tick then
            local force = game.forces[force_name]
            if force and force.valid then
                for _, surface in pairs(state.ship_surfaces) do
                    if surface and surface.valid then
                        deactivate_cloak(force, surface)
                    end
                end
            end
        end
        
        if state.cryo_freeze_end_tick and tick >= state.cryo_freeze_end_tick then
            if has_frozen_players(state) then
                deactivate_cryo_freeze(force_name)
            end
        end
    end
end

-- Обработчик нажатия кнопки способности
function ship_abilities.on_gui_click(event)
    if not event or not event.element or not event.player_index then return end
    
    -- ОПТИМИЗАЦИЯ: ранний выход для всех не-способностей
    if not string.match(event.element.name, "^wdm%-ability%-button%-") then
        return
    end
    
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    
    local element_name = event.element.name
    debug("[ship_abilities] on_gui_click: element_name=" .. element_name .. ", player.surface=" .. player.surface.name)
    
    local ability_name = string.sub(element_name, 20)
    local force = player.force
    if not force or not force.valid then return end
    
    if not is_ability_unlocked(force, ability_name) then
        player.print({"wdm-expansion.ship-ability-not-unlocked"})
        return
    end
    
    local cooldown = get_ability_cooldown_remaining(force.name, ability_name)
    if cooldown > 0 then
        player.print({"wdm-expansion.ship-ability-on-cooldown", math.ceil(cooldown / 60)})
        return
    end
    
    local state = get_force_state(force.name)
    -- Инициализация ability_uses для старых сохранений
    state.ability_uses = state.ability_uses or {}
    debug("[ship_abilities] on_gui_click: force=" .. force.name .. ", ship_surfaces count=" .. (state.ship_surfaces and #state.ship_surfaces or 0))
    
    -- Если поверхности не инициализированы, находим их сейчас (fallback)
    if not state.ship_surfaces or #state.ship_surfaces == 0 then
        state.ship_surfaces = {}
        for _, surface in pairs(game.surfaces) do
            if surface and surface.valid and string.match(surface.name, "^ship_interior") then
                table.insert(state.ship_surfaces, surface)
                debug("[ship_abilities]   found ship surface: " .. surface.name)
            end
        end
        debug("[ship_abilities] Fallback: found " .. #state.ship_surfaces .. " ship surfaces")
    end
    
    if not state.ship_surfaces or #state.ship_surfaces == 0 then
        player.print({"wdm-expansion.ship-surface-not-found"})
        return
    end
    
    local ability_config = ABILITIES_CONFIG[ability_name]
    if not ability_config then return end
    
    -- Проверка лимита использований за варп
    if ability_config.max_uses_per_warp then
        local uses = state.ability_uses[ability_name] or 0
        if uses >= ability_config.max_uses_per_warp then
            player.print({"wdm-expansion.ship-ability-max-uses-reached", ability_config.max_uses_per_warp})
            return
        end
    end
    
    -- Создаем список всех поверхностей (хеш-таблица для уникальности)
    local all_surfaces = {}
    if player.surface and player.surface.valid then
        all_surfaces[player.surface.name] = player.surface
    end
    for _, ship_surface in pairs(state.ship_surfaces) do
        if ship_surface and ship_surface.valid then
            all_surfaces[ship_surface.name] = ship_surface
        end
    end
    
    if not next(all_surfaces) then
        player.print({"wdm-expansion.ship-surface-not-found"})
        return
    end
    
    -- Проверка возможности применения способности (до траты ресурсов)
    if ability_name == "reactor_boost" then
        if not check_reactor_boost(force, all_surfaces) then
            player.print({"wdm-expansion.reactor-boost-no-reactors"})
            return
        end
    elseif ability_name == "ammo_distributor" then
        local has_turrets, has_ammo = check_ammo_distributor_turrets_and_ammo(force, all_surfaces)
        if not has_turrets then
            player.print({"wdm-expansion.ammo-distributor-no-turrets"})
            return
        end
        if not has_ammo then
            player.print({"wdm-expansion.ammo-distributor-no-ammo"})
            return
        end
    elseif ability_name == "resource_collector" then
        if not check_resource_collector_items(force, all_surfaces) then
            player.print({"wdm-expansion.resource-collector-no-items-on-ground"})
            return
        end
    elseif ability_name == "cryo_freeze" then
        if not check_cryo_freeze_players(force, all_surfaces) then
            player.print({"wdm-expansion.cryo-freeze-no-players"})
            return
        end
    elseif ability_name == "waste_recycler" then
        local state = get_force_state(force.name)
        local item_to_recycle = state.waste_recycler_item
        if not item_to_recycle or not item_to_recycle.name then
            player.print({"wdm-expansion.waste-recycler-no-item-selected"})
            return
        end
        if item_to_recycle.name == "scrap" then
            player.print({"wdm-expansion.waste-recycler-cannot-recycle"})
            return
        end
        if not check_waste_recycler_has_items(force, all_surfaces, item_to_recycle.name) then
            player.print({"wdm-expansion.waste-recycler-no-items"})
            return
        end
    end
    
    -- Проверяем ресурсы
    if ability_config.cost_fluid then
        local has_fluid = false
        local resource_surface = nil
        for _, s in pairs(all_surfaces) do
            local ok, tank = has_warponium_fluid(s, ability_config.cost_fluid)
            if ok then
                has_fluid = true
                resource_surface = s
                break
            end
        end
        if not has_fluid then
            player.print({"wdm-expansion.ship-not-enough-warponium"})
            return
        end
        consume_warponium_fluid(resource_surface, ability_config.cost_fluid)
        debug("[ship_abilities] Consumed resources from: " .. resource_surface.name)
    end
    
    local activated_any = false
    
    -- Ammo distributor + Waste recycler: один вызов со ВСЕМИ поверхностями
    if ability_name == "ammo_distributor" then
        if activate_ammo_distributor(force, all_surfaces) then activated_any = true end
    elseif ability_name == "waste_recycler" then
        if activate_waste_recycler(force, all_surfaces) then activated_any = true end
    elseif ability_name == "reactor_boost" then
        if activate_reactor_boost(force, all_surfaces) then activated_any = true end
    elseif ability_name == "cryo_freeze" then
        if activate_cryo_freeze(force, all_surfaces) then activated_any = true end
    elseif ability_name == "cloak" then
        if activate_cloak(force, all_surfaces) then activated_any = true end
    elseif ability_name == "resource_collector" then
        if activate_resource_collector(force, all_surfaces) then activated_any = true end
    end

    if activated_any then
        state.ability_cooldowns[ability_name] = game.tick + ability_config.cooldown_ticks
        state.ability_uses[ability_name] = (state.ability_uses[ability_name] or 0) + 1
        debug("[ship_abilities] Uses for " .. ability_name .. ": " .. state.ability_uses[ability_name])
        
        -- Воспроизводим звук активации способности
        game.play_sound({path = "reactor-stabilized"})
    end
end

function ship_abilities.init()
    init_storage()
    rebuild_fluid_tank_destroy_registrations()
end

function ship_abilities.on_load()
    if storage.ship_abilities and storage.ship_abilities.force_states then
        for force_name, state in pairs(storage.ship_abilities.force_states) do
            if state.resource_collector_target then
                debug("[ship_abilities] on_load: marking resource_collector_target for validation for force: " .. force_name)
            end
        end
    end
end

-- Экспорт для восстановления регистраций при configuration_changed
function ship_abilities.rebuild_fluid_tank_registrations()
    rebuild_fluid_tank_destroy_registrations()
end

-- Экспортированные функции
function ship_abilities.get_abilities_config()
    return ABILITIES_CONFIG
end

function ship_abilities.is_ability_unlocked(force, ability_name)
    return is_ability_unlocked(force, ability_name)
end

function ship_abilities.get_ability_cooldown_remaining(force_name, ability_name)
    return get_ability_cooldown_remaining(force_name, ability_name)
end

function ship_abilities.update_ticker_state()
    return update_ticker_state()
end

function ship_abilities.get_ability_uses_remaining(force_name, ability_name)
    local state = get_force_state(force_name)
    -- Инициализация ability_uses для старых сохранений, где поле могло отсутствовать
    state.ability_uses = state.ability_uses or {}
    local config = ABILITIES_CONFIG[ability_name]
    if not config or not config.max_uses_per_warp then return nil end
    local uses = state.ability_uses[ability_name] or 0
    return config.max_uses_per_warp - uses
end

function ship_abilities.set_resource_collector_target(force_name, entity)
    if not (force_name and entity and entity.valid) then return end
    local state = get_force_state(force_name)
    state.resource_collector_target = {
        name = entity.name,
        surface_index = entity.surface.index,
        position = {x = entity.position.x, y = entity.position.y}
    }
    debug("[ship_abilities] Target chest set: "..entity.name)
end

function ship_abilities.get_resource_collector_target(force_name)
    local state = get_force_state(force_name)
    if not state.resource_collector_target then return nil end
    
    local entity = find_entity_for_target(state.resource_collector_target)
    if entity and entity.valid then
        return entity.unit_number, entity.localised_name or entity.name, entity.surface.name
    end
    
    state.resource_collector_target = nil
    return nil
end

function ship_abilities.get_target_chest_info(force_name)
    local state = get_force_state(force_name)
    if not state.resource_collector_target then return nil end
    
    local entity = find_entity_for_target(state.resource_collector_target)
    if entity and entity.valid then
        return {name = entity.localised_name or entity.name, surface = entity.surface.name}
    end
    
    if state.resource_collector_target then
        local s = state.resource_collector_target.surface_index and game.surfaces[state.resource_collector_target.surface_index]
        return {
            name = state.resource_collector_target.name,
            surface = s and s.valid and s.name or "unknown",
            lost = true
        }
    end
    
    return nil
end

function ship_abilities.set_waste_recycler_item(force_name, item_name)
    if not force_name then return end
    local state = get_force_state(force_name)
    if item_name then
        state.waste_recycler_item = {name = item_name}
        debug("[ship_abilities] Waste recycler item set: " .. item_name)
    else
        state.waste_recycler_item = nil
        debug("[ship_abilities] Waste recycler item cleared")
    end
end

function ship_abilities.get_waste_recycler_item(force_name)
    local state = get_force_state(force_name)
    return state.waste_recycler_item
end

function ship_abilities.start_chest_selection_mode(player_index)
    if not storage.ship_abilities then return end
    storage.ship_abilities.player_chest_selection_mode = storage.ship_abilities.player_chest_selection_mode or {}
    storage.ship_abilities.player_chest_selection_mode[player_index] = true
end

function ship_abilities.stop_chest_selection_mode(player_index)
    if not storage.ship_abilities or not storage.ship_abilities.player_chest_selection_mode then return end
    storage.ship_abilities.player_chest_selection_mode[player_index] = nil
end

function ship_abilities.is_in_chest_selection_mode(player_index)
    if not storage.ship_abilities or not storage.ship_abilities.player_chest_selection_mode then return false end
    return storage.ship_abilities.player_chest_selection_mode[player_index] or false
end

function ship_abilities.on_gui_opened(event)
    if not event or not event.gui_type then return end
    
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    
    if ship_abilities.is_in_chest_selection_mode(event.player_index) then
        if event.gui_type == defines.gui_type.entity and event.entity and event.entity.valid then
            local entity = event.entity
            if entity.type == "container" or entity.type == "logistic-container" then
                ship_abilities.set_resource_collector_target(player.force.name, entity)
                ship_abilities.stop_chest_selection_mode(event.player_index)
                
                if event.gui_element and event.gui_element.valid then
                    event.gui_element.destroy()
                end
                
                player.print({"wdm-expansion.chest-selector-target-set"})
                return
            end
        end
    end
end

function ship_abilities.on_entity_cloned(event)
    local source = event.source
    if not (source and source.valid) then return end
    
    local destination = event.destination
    if not (destination and destination.valid) then return end
    
    -- Обработка клонирования storage-tank (происходит при варпе)
    if source.type == "storage-tank" or source.name == "storage-tank" then
        local old_id = source.unit_number
        local new_id = destination.unit_number
        local dest_pos = destination.position
        
        -- Сохраняем новый tank (даже если старый уже был удалён через on_object_destroyed)
        if new_id then
            storage.ship_abilities.fluid_tanks[new_id] = {
                surface_index = destination.surface.index,
                position = {x = dest_pos.x, y = dest_pos.y}
            }
            fluid_tank_cache[new_id] = destination
            register_fluid_tank_for_destroy_event(destination)
            debug("[ship_abilities] Fluid tank registered after cloning: new_id=" .. new_id)
        end
        
        -- Очищаем старый, если он ещё существует
        if old_id then
            remove_fluid_tank_by_unit_number(old_id)
            debug("[ship_abilities] Fluid tank removed after cloning: old_id=" .. old_id)
        end
    end
    
    for force_name, state in pairs(storage.ship_abilities.force_states or {}) do
        if state.resource_collector_target then
            if source.name == state.resource_collector_target.name and
               source.surface.index == state.resource_collector_target.surface_index and
               source.position.x == state.resource_collector_target.position.x and
               source.position.y == state.resource_collector_target.position.y then
                state.resource_collector_target = {
                    name = destination.name,
                    surface_index = destination.surface.index,
                    position = {x = destination.position.x, y = destination.position.y}
                }
                debug("[ship_abilities] Target chest updated after cloning for force: " .. force_name)
            end
        end
    end
end

return ship_abilities
