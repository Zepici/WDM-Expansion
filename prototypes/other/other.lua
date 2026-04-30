local utils = require("utils")
if mods["Cold_biters"] then
    data.raw["armor"]["cb-modular-armor"].resistances =
    {
        {
            type = "acid",
            percent = 60
        },
        {
            type = "cold",
            percent = 50
        },
        {
            type = "explosion",
            percent = -35
        },
        {
            type = "fire",
            percent = -50
        },       
        {
            type = "physical",
            percent = 40,
            decrease = 6
        }
    }
    data.raw["armor"]["cb-power-armor"].resistances =
    {
        {
            type = "acid",
            percent = 70
        },
        {
            type = "cold",
            percent = 70
        },
        {
            type = "explosion",
            percent = -40
        },
        {
            type = "fire",
            percent = -60
        },       
        {
            type = "physical",
            percent = 40,
            decrease = 8
        }
    }
    data.raw["armor"]["cb-power-armor-mk2"].resistances =
    {
        {
            type = "acid",
            percent = 80
        },
        {
            type = "cold",
            percent = 80
        },
        {
            type = "explosion",
            percent = -50
        },
        {
            type = "fire",
            percent = -70
        },       
        {
            type = "physical",
            percent = 50,
            decrease = 10
        }
    }
end

data.raw["generator-equipment"]["pamk3-se"].power = "5MW"

data.raw["technology"]["pamk3-pdd"].icons[1].icon = "__Warp-Drive-Machine-Expansion__/graphics/equipment/discharge-defense-equipment.png"
data.raw["technology"]["pamk3-pdd"].icons[1].icon_size = 256

data.raw["active-defense-equipment"]["pamk3-pdd"].sprite = {
    filename = "__Warp-Drive-Machine-Expansion__/graphics/equipment/discharge-defense-equipment.png",
    width = 256,
    height = 256
}
data.raw["item"]["pamk3-pdd"].icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/discharge-defense-equipment.png"
data.raw["ammo"]["kj_laser_normal"].ammo_type.action.range = 70
data.raw["electric-turret"]["kj_electric_laser"].attack_parameters.ammo_type.action.range = 70
data.raw["electric-turret"]["kj_electric_laser"].attack_parameters.ammo_type.action.width = 6
data.raw["fluid"]["warponium-fluid"].subgroup = "fluid"
data.raw["item-with-entity-data"]["kj_laser"].hidden = true
data.raw["item-with-entity-data"]["kj_laser"].hidden_in_factoriopedia = true
data.raw["recipe"]["kj_laser"].hidden = true
data.raw["recipe"]["kj_laser"].hidden_in_factoriopedia = true
data.raw["ammo-turret"]["kj_laser"].hidden = true
data.raw["ammo-turret"]["kj_laser"].hidden_in_factoriopedia = true
data.raw["electric-turret"]["kj_electric_laser"].hidden = true
data.raw["electric-turret"]["kj_electric_laser"].hidden_in_factoriopedia = true
data.raw["artillery-turret"]["artillery-turret"].manual_range_modifier = 1.3
data.raw["active-defense-equipment"]["pamk3-pdd"].attack_parameters.range = 12
if mods["space-age"] then
    data.raw["ammo-turret"]["wdm_pirate_railgun-turret"].energy_per_shot = "0kJ"
    data.raw["ammo-turret"]["wdm_pirate_railgun-turret"].energy_source.render_no_network_icon = false
    data.raw["ammo-turret"]["wdm_pirate_railgun-turret"].energy_source.render_no_power_icon = false
end
table.insert(data.raw.wall["stone-wall"].resistances, {type = "electric", percent = 70})
table.insert(data.raw.gate["gate"].resistances, {type = "electric", percent = 70})

local function scale_sound_volume(sound, multiplier)
    if type(sound) ~= "table" then return end

    if sound.volume then
        sound.volume = sound.volume * multiplier
    end

    if sound.min_volume then
        sound.min_volume = sound.min_volume * multiplier
    end

    if sound.max_volume then
        sound.max_volume = sound.max_volume * multiplier
    end

    for _, value in pairs(sound) do
        if type(value) == "table" then
            scale_sound_volume(value, multiplier)
        end
    end
end

if mods["space-age"] then
    local base_explosion = data.raw["explosion"]["cyborg_electric_projectile_explosion"]

    if base_explosion and not data.raw["explosion"]["wdm-cyborg_electric_projectile_explosion_quiet"] then
        local quiet_explosion = table.deepcopy(base_explosion)
        quiet_explosion.name = "wdm-cyborg_electric_projectile_explosion_quiet"
        scale_sound_volume(quiet_explosion.sound, 0.8)
        data:extend({ quiet_explosion })
    end
end

local proj = data.raw["artillery-projectile"]["wdm-blast-projectile"]

if proj then
    -- Увеличиваем визуальный размер
    if proj.picture then
        proj.picture.scale = 2
    end

    -- Определяем entity_name для взрыва в зависимости от модов
    local explosion_entity_name
    if mods["space-age"] then
        explosion_entity_name = "wdm-cyborg_electric_projectile_explosion_quiet"
    else
        explosion_entity_name = "medium-explosion"  -- или другой ванильный взрыв
    end

    proj.action = {
        type = "area",
        radius = 25,
        action_delivery = {
            type = "instant",
            target_effects = {
                {
                    type = "damage",
                    damage = {
                        amount = 2000,
                        type = "electric"
                    }
                },
                {
                    type = "create-entity",
                    entity_name = explosion_entity_name  -- Используем определенное имя
                }
            }
        }
    }
end

-- Проверяем, включена ли настройка мода "zombie"
if settings.startup["wdm-expansion-zombie"] and settings.startup["wdm-expansion-zombie"].value then

    local function buff_unit(unit_name)
        local unit = data.raw["unit"][unit_name]
        if not unit then return end

        -- Безопасно увеличиваем урон
        if unit.attack_parameters then
            if unit.attack_parameters.damage_modifier then
                unit.attack_parameters.damage_modifier = 2
            else
                unit.attack_parameters.damage_modifier = 2
            end
        end

        -- Увеличиваем здоровье
        if unit.max_health then
            unit.max_health = unit.max_health * 2
        end
    end

    -- Список всех зомби
    local zombies = {
        "small-biter-zombie", "medium-biter-zombie", "big-biter-zombie", "behemoth-biter-zombie",
        "small-spitter-zombie", "medium-spitter-zombie", "big-spitter-zombie", "behemoth-spitter-zombie"
    }

    for _, name in pairs(zombies) do
        buff_unit(name)
    end
end

