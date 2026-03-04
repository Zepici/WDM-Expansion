local utils = require("utils")

utils.modify_size(data.raw["electric-turret"]["kj_electric_laser"], 2)
--utils.modify_size(data.raw["electric-turret"]["kj_electric_laser_player"], 1.5)
data.raw["electric-turret"]["kj_electric_laser"].attack_parameters.minimum_attack_cycle_duration = 200

utils.disable_data(data.raw["technology"], require("prototypes.technologies.disabled"))
utils.disable_data(data.raw["recipe"], require("prototypes.recipes.disabled"))

local function deepcopy(orig)
    return table.deepcopy(orig)
end

local base_turret = data.raw["electric-turret"]["kj_electric_laser"]
local base_ammo = data.raw["ammo"]["kj_laser_normal"].ammo_type

for tier = 1, 10 do
    local turret = deepcopy(base_turret)
    local ammo = deepcopy(base_ammo)

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
    ammo.action.action_delivery.target_effects[1].damage.amount =
    ammo.action.action_delivery.target_effects[1].damage.amount + (tier * 200)
    data:extend({ turret })
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