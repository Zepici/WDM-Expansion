local utils = require("utils")
require("prototypes.entity.turret_buff")
require("prototypes.items.turret_buff")

local wdm_difficulty_setting = data.raw["int-setting"] and data.raw["int-setting"]["wdm-difficulty-level"]
if wdm_difficulty_setting then
    wdm_difficulty_setting.default_value = 2
end

for _, recipe_name in pairs({
    "warponium-plate",
    "warponium-fluid",
    "crystal-processing",
    "crystal-processing-t2"
}) do
    local recipe = data.raw["recipe"] and data.raw["recipe"][recipe_name]
    if recipe then
        recipe.category = "warponium"
    end
end

local exclude_names = {
    ["wdm_pirate_ship_search_probe"] = true
}

local function should_patch_factoriopedia_simulation(prototype_name)
    if type(prototype_name) ~= "string" then return false end
    
    if exclude_names[prototype_name] then
        return false
    end
    
    return string.sub(prototype_name, 1, #"wdm_pirate") == "wdm_pirate"
        or string.sub(prototype_name, 1, #"cyborg_strafer") == "cyborg_strafer"
        or string.sub(prototype_name, 1, #"maf-boss") == "maf-boss"
        or string.sub(prototype_name, 1, #"mind-control-unit") == "mind-control-unit"
        or (mods["ZombieHordeFaction"]
            and string.find(prototype_name, "zombie", 1, true))
        or (mods["ArmouredBiters"]
            and string.find(prototype_name, "armoured-biter", 1, true))
        or (mods["Arachnids_enemy"] and (
                string.find(prototype_name, "arachnid-biter", 1, true)
                or string.find(prototype_name, "arachnid-spitter", 1, true)
            ))
        or (mods["Cold_biters"] and (
                string.find(prototype_name, "cold-biter", 1, true)
                or string.find(prototype_name, "cold-spitter", 1, true)
            ))
        or (mods["Toxic_biters"] and (
                string.find(prototype_name, "toxic-biter", 1, true)
                or string.find(prototype_name, "toxic-spitter", 1, true)
            ))
        or (mods["Explosive_biters"] and (
                string.find(prototype_name, "explosive-biter", 1, true)
                or string.find(prototype_name, "explosive-spitter", 1, true)
            ))
end
local function is_boss(prototype_name)
    return type(prototype_name) == "string"
        and (
            string.find(prototype_name, "wdm_pirate_boss", 1, true)
            or string.find(prototype_name, "cyborg_strafer-boss", 1, true)
            or string.find(prototype_name, "maf-boss", 1, true)
            or string.find(prototype_name, "mind-control-unit", 1, true)
        )
end
local function get_boss_level(prototype_name)
    if type(prototype_name) ~= "string" then return nil end

    local num = string.match(prototype_name, "%d+")
    num = tonumber(num)

    if num and num >= 1 and num <= 10 then
        return num
    end

    return nil
end
local function patch_simulation_init(init_code, prototype_name)
    if type(init_code) ~= "string" or init_code == "" then return init_code end

    local patched_lines = {}
    local boss = is_boss(prototype_name)

    local zoom_value = nil

    if boss then
        local level = get_boss_level(prototype_name)
        if level then
            zoom_value = 1 - (level * 0.015)
        else
            zoom_value = 1
        end
    end
    for line, newline in init_code:gmatch("([^\r\n]*)(\r?\n?)") do
        if line == "" and newline == "" then break end

        -- Патч entity name
        if string.find(line, "create_entity", 1, true) then
            line = line:gsub('name%s*=%s*"[^"]+"', 'name = "' .. prototype_name .. '"', 1)
        end

        -- Патч zoom
        if boss and zoom_value then
            if string.find(line, "zoom", 1, true) then
                line = line:gsub('zoom%s*=%s*[%d%.]+', 'zoom = ' .. zoom_value, 1)
            end
        end

        patched_lines[#patched_lines + 1] = line .. newline
    end

    return table.concat(patched_lines)
end
local function get_fallback_simulation()
    local base = data.raw.unit and data.raw.unit["small-biter"]
    if base and base.factoriopedia_simulation then
        return table.deepcopy(base.factoriopedia_simulation)
    end
    return nil
end
for _, prototypes in pairs(data.raw or {}) do
    for prototype_name, prototype in pairs(prototypes or {}) do

        if should_patch_factoriopedia_simulation(prototype_name) then
            local simulation = prototype.factoriopedia_simulation
            if not simulation then
                simulation = get_fallback_simulation()
                prototype.factoriopedia_simulation = simulation
            end

            if simulation and simulation.init and not simulation.init_file then
                simulation.init = patch_simulation_init(simulation.init, prototype_name)
            end

        end
    end
end

local targets = {
    ["wdm-ore-warponium"] = true,
    ["underground-warponium"] = true
}

local iron_ore = data.raw.resource and data.raw.resource["iron-ore"]
local base_simulation = iron_ore and iron_ore.factoriopedia_simulation

if base_simulation and base_simulation.init and not base_simulation.init_file then
    for name in pairs(targets) do
        local res = data.raw.resource and data.raw.resource[name]
        if res then
            local sim = table.deepcopy(base_simulation)
            local patched_lines = {}
            
            -- Построчно меняем имя руды во всех вызовах create_entity
            for line, newline in sim.init:gmatch("([^\r\n]*)(\r?\n?)") do
                if line == "" and newline == "" then break end
                
                if string.find(line, "create_entity", 1, true) then
                    line = line:gsub('name%s*=%s*"[^"]+"', 'name = "' .. name .. '"', 1)
                end
                
                patched_lines[#patched_lines + 1] = line .. newline
            end
            
            sim.init = table.concat(patched_lines)
            res.factoriopedia_simulation = sim
        end
    end
end



local red_refined_concrete = data.raw.item and data.raw.item["red-refined-concrete"]
if red_refined_concrete then
    red_refined_concrete.custom_tooltip_fields = red_refined_concrete.custom_tooltip_fields or {}
    table.insert(red_refined_concrete.custom_tooltip_fields, {
        value = "",
        name = {"item-description.wdm-red-refined-concrete-bonus"}
    })
end

for level = 1, 6 do
    local tech = data.raw.technology and data.raw.technology["wdm_external_defense_ship_platform-" .. level]
    if tech then
        local base_description = tech.localised_description or {"technology-description.wdm_external_defense_ship_platform"}
        tech.localised_description = {
            "",
            base_description,
            "\n",
            {"technology-description.wdm-red-refined-concrete-bonus"}
        }
    end
end

utils.modify_size(data.raw["electric-turret"]["kj_electric_laser"], 2)
--utils.modify_size(data.raw["electric-turret"]["kj_electric_laser_player"], 1.5)
data.raw["electric-turret"]["kj_electric_laser"].attack_parameters.minimum_attack_cycle_duration = 200

utils.disable_data(data.raw["technology"], require("prototypes.technologies.disabled"))
utils.disable_data(data.raw["recipe"], require("prototypes.recipes.disabled"))

local function deepcopy(orig)
    return table.deepcopy(orig)
end

local BUFFED_TURRET_PREFIX = "wdm-red-concrete-buffed-"

local function add_turret_attack_effects(source_turret_name, target_turret_name)
    if not source_turret_name or not target_turret_name or source_turret_name == target_turret_name then return end

    for _, technology in pairs(data.raw.technology or {}) do
        local effects = technology.effects
        if effects then
            local has_target_effect = false

            for _, effect in pairs(effects) do
                if effect.type == "turret-attack" and effect.turret_id then
                    if effect.turret_id == target_turret_name then
                        has_target_effect = true
                    end
                end
            end

            if not has_target_effect then
                for _, effect in pairs(effects) do
                    if effect.type == "turret-attack" and effect.turret_id == source_turret_name then
                        local copied_effect = deepcopy(effect)
                        copied_effect.turret_id = target_turret_name
                        table.insert(effects, copied_effect)
                    end
                end
            end
        end
    end
end

local function add_buffed_turret_attack_effects()
    for _, turret_type in ipairs({"ammo-turret", "electric-turret"}) do
        for turret_name in pairs(data.raw[turret_type] or {}) do
            if string.sub(turret_name, 1, #BUFFED_TURRET_PREFIX) == BUFFED_TURRET_PREFIX then
                local base_name = string.sub(turret_name, #BUFFED_TURRET_PREFIX + 1)
                if data.raw[turret_type][base_name] then
                    add_turret_attack_effects(base_name, turret_name)
                end
            end
        end
    end
end

local function find_first_damage_amount(node)
    if type(node) ~= "table" then return nil end

    if node.damage and type(node.damage) == "table" and type(node.damage.amount) == "number" then
        return node.damage.amount
    end

    for _, value in pairs(node) do
        if type(value) == "table" then
            local amount = find_first_damage_amount(value)
            if amount then
                return amount
            end
        end
    end
end

local base_turret = data.raw["electric-turret"]["kj_electric_laser"]
local base_ammo = data.raw["ammo"]["kj_laser_normal"].ammo_type
local base_laser_damage = find_first_damage_amount(base_ammo.action) or 0
local base_damage_modifier = (base_turret.attack_parameters and base_turret.attack_parameters.damage_modifier) or 1
local mini_turret = deepcopy(data.raw["electric-turret"]["kj_electric_laser_player"])
local mini_item = deepcopy(data.raw["item-with-entity-data"]["kj_electric_laser_player"])
local mini_recipe = deepcopy(data.raw["recipe"]["kj_electric_laser_player"])

mini_turret.name = "kj_electric_laser_mini"
mini_turret.max_health = 3000
mini_turret.attack_parameters.damage_modifier = 0.3
mini_turret.attack_parameters.ammo_type = deepcopy(data.raw["ammo"]["kj_laser_normal"].ammo_type)
mini_turret.attack_parameters.ammo_type.energy_consumption = "0MJ"
mini_turret.attack_parameters.range = 50
mini_turret.prepare_range = 50
mini_turret.energy_source = {
    type = "void",
    emissions_per_minute = {},
    render_no_network_icon = true,
    render_no_power_icon = true
}

 mini_item.name = "kj_electric_laser_mini"
 mini_item.place_result = "kj_electric_laser_mini"

 mini_item.hidden = true
 mini_turret.hidden = true
 mini_item.hidden_in_factoriopedia = false
 mini_turret.hidden_in_factoriopedia = false

 mini_recipe.name = "kj_electric_laser_mini"
 if mini_recipe.results then
     for _, result in pairs(mini_recipe.results) do
         if result.name == "kj_electric_laser_player" then
             result.name = "kj_electric_laser_mini"
         end
     end
 end
 if mini_recipe.result == "kj_electric_laser_player" then
     mini_recipe.result = "kj_electric_laser_mini"
 end

data:extend({ mini_turret, mini_item })

local scaled_boss_loot = deepcopy(data.raw.unit["maf-boss-biter-1"].loot or {})
for _, drop in pairs(scaled_boss_loot) do
    if drop.probability then
        drop.probability = drop.probability / 1.3
    end
end

for tier = 1, 10 do
    local turret = deepcopy(base_turret)
    local ammo = deepcopy(base_ammo)
    local target_laser_damage = base_laser_damage + (tier * 220)

    turret.name = "kj_electric_laser_t" .. tier
    turret.loot = deepcopy(scaled_boss_loot)
    turret.minable = nil -- чтобы игрок не мог разобрать
    turret.max_health = base_turret.max_health * tier                        -- здоровье растёт
    turret.rotation_speed = base_turret.rotation_speed + (tier * 0.001)     -- чуть быстрее крутится

    -- Атака босса
    turret.attack_parameters.cooldown = math.max(60, base_turret.attack_parameters.cooldown - tier * 60)  -- быстрее стреляет
    --turret.attack_parameters.range = base_turret.attack_parameters.range + tier * 10                      -- дальность растёт
    turret.attack_parameters.minimum_attack_cycle_duration = turret.attack_parameters.cooldown                 -- важно!
    turret.attack_parameters.ammo_type = ammo

    -- сила лазера (урон)
    if base_laser_damage > 0 then
        turret.attack_parameters.damage_modifier = base_damage_modifier * (target_laser_damage / base_laser_damage)
    end
    data:extend({ turret })
end

local tesla_turret = data.raw["electric-turret"] and data.raw["electric-turret"]["tesla-turret"]

if mods["space-age"]
    and tesla_turret
    and tesla_turret.attack_parameters
    and tesla_turret.attack_parameters.ammo_type
    and tesla_turret.attack_parameters.ammo_type.action then
    for tier = 1, 10 do
        local base_name = "kj_electric_laser_t" .. tier
        local base_variant = data.raw["electric-turret"][base_name]
        if base_variant and base_variant.attack_parameters and base_variant.attack_parameters.ammo_type then
            local elite = deepcopy(base_variant)
            elite.name = base_name .. "_tesla"
            elite.localised_name = {"entity-name." .. base_name}
            elite.localised_description = {"entity-description." .. base_name}
            elite.attack_parameters.range = math.max(
                elite.attack_parameters.range or 0,
                tesla_turret.attack_parameters.range or 0
            )
            elite.attack_parameters.ammo_type.action = {
                deepcopy(base_variant.attack_parameters.ammo_type.action),
                deepcopy(tesla_turret.attack_parameters.ammo_type.action)
            }
            data:extend({ elite })
        end
    end
end

add_turret_attack_effects("laser-turret", "kj_electric_laser_player")
add_turret_attack_effects("laser-turret", "kj_electric_laser_mini")
add_buffed_turret_attack_effects()
-- Настройка спавнеров зомби
if settings.startup["wdm-expansion-zombie"] and settings.startup["wdm-expansion-zombie"].value then
    local unit_spawner = data.raw["unit-spawner"]["biter-zombie-spawner"]
    if unit_spawner then
        unit_spawner.spawning_cooldown = {200, 1}
        unit_spawner.max_count_of_owned_units = 25
        unit_spawner.max_count_of_owned_defensive_units = 25
    end
    
    local spitter_spawner = data.raw["unit-spawner"]["spitter-zombie-spawner"]
    if spitter_spawner then
        spitter_spawner.spawning_cooldown = {200, 1}
        spitter_spawner.max_count_of_owned_units = 25
        spitter_spawner.max_count_of_owned_defensive_units = 25
    end    
end

--[[
if data.raw.planet["nauvis"] then
    local map_gen = data.raw.planet["nauvis"].map_gen_settings
    map_gen.autoplace_controls = map_gen.autoplace_controls or {}
    map_gen.autoplace_controls["warponium-ore"] = {}
    
    map_gen.autoplace_settings = map_gen.autoplace_settings or {}
    map_gen.autoplace_settings.entity = map_gen.autoplace_settings.entity or {}
    map_gen.autoplace_settings.entity.settings = map_gen.autoplace_settings.entity.settings or {}
    map_gen.autoplace_settings.entity.settings["warponium-ore"] = {}
end
if data.raw["map-gen-presets"] and data.raw["map-gen-presets"]["default"] then
    for _, preset in pairs(data.raw["map-gen-presets"]["default"]) do
        if preset.basic_settings then
            preset.basic_settings.autoplace_controls = preset.basic_settings.autoplace_controls or {}
            preset.basic_settings.autoplace_controls["warponium-ore"] = {}
            preset.basic_settings.autoplace_settings = preset.basic_settings.autoplace_settings or {}
            preset.basic_settings.autoplace_settings.entity = preset.basic_settings.autoplace_settings.entity or {}
            preset.basic_settings.autoplace_settings.entity.settings = preset.basic_settings.autoplace_settings.entity.settings or {}
            preset.basic_settings.autoplace_settings.entity.settings["warponium-ore"] = {}
        end
    end
end
]]



