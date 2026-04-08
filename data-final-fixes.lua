local utils = require("utils")
require("prototypes.entity.turret_buff")
require("prototypes.items.turret_buff")

local wdm_difficulty_setting = data.raw["int-setting"] and data.raw["int-setting"]["wdm-difficulty-level"]
if wdm_difficulty_setting then
    wdm_difficulty_setting.default_value = 2
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

for tier = 1, 10 do
    local turret = deepcopy(base_turret)
    local ammo = deepcopy(base_ammo)
    local target_laser_damage = base_laser_damage + (tier * 220)

    turret.name = "kj_electric_laser_t" .. tier
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
