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
data.raw["recipe"]["warponium-fluid"].energy_required = 50
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

data.raw["resource"]["wdm-ore-warponium"].category = "warponium-solid"

data:extend({
  {
    type = "corpse",
    name = "ship-abilities-console-corpse",
    icon_size = 64,
    icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/ship-abilities-console.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden = true,
    selectable_in_game = false,
    time_before_removed = 7200,
    final_render_layer = "remnants",
    animation = {
      filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/ship-abilities-console/ship-abilities-console-corpse.png",
      priority = "extra-high",
      width = 700,
      height = 800,
      frame_count = 1,
      direction_count = 1,
      scale = 0.25
    }
  }
})

local new_dummy = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud-visual-dummy"])
new_dummy.name = "diluted-big-poison-cloud-visual-dummy"
new_dummy.color = {0.15, 0.15, 0.15, 0.550}
new_dummy.duration = 60 * 60
data:extend({new_dummy})
local new_cloud = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])
new_cloud.name = "dangerous-big-poison-cloud"
new_cloud.action.action_delivery.target_effects.action.radius = 22
new_cloud.action.action_delivery.target_effects.action.action_delivery.target_effects.damage.amount = 4
new_cloud.particle_count = 80
new_cloud.particle_spread[1] = new_cloud.particle_spread[1] * 2
new_cloud.particle_spread[2] = new_cloud.particle_spread[2] * 2
new_cloud.color = {0.15, 0.15, 0.15, 0.550}
new_cloud.duration = 60 * 60
local mid_cluster = table.deepcopy(new_cloud.created_effect[1])
mid_cluster.cluster_count = 35
mid_cluster.distance = 12
mid_cluster.distance_deviation = 5
mid_cluster.action_delivery.target_effects[1].entity_name = "diluted-big-poison-cloud-visual-dummy"
new_cloud.created_effect[1].cluster_count = 30
new_cloud.created_effect[1].distance = 6
new_cloud.created_effect[1].distance_deviation = 4
new_cloud.created_effect[1].action_delivery.target_effects[1].entity_name = "diluted-big-poison-cloud-visual-dummy"
new_cloud.created_effect[2].cluster_count = 45
new_cloud.created_effect[2].distance = 17.6
new_cloud.created_effect[2].distance_deviation = 4
new_cloud.created_effect[2].action_delivery.target_effects[1].entity_name = "diluted-big-poison-cloud-visual-dummy"
table.insert(new_cloud.created_effect, mid_cluster)
data:extend({new_cloud})

--2 облако

local colors = {
  {0.9, 0.1, 0.1, 0.65},
  {0.9, 0.8, 0.0, 0.65},
  {0.9, 0.4, 0.0, 0.65},
  {0.9, 0.2, 0.6, 0.65}
}
for i, color in ipairs(colors) do
  local new_dummy = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud-visual-dummy"])
  new_dummy.name = "rainbow-mini-smoke-dummy-" .. i
  new_dummy.color = color
  new_dummy.duration = 60 * 60
  data:extend({new_dummy})
end
local new_cloud = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])
new_cloud.name = "rainbow-mini-poison-cloud"
new_cloud.action.action_delivery.target_effects.action.radius = 5.5
new_cloud.action.action_delivery.target_effects.action.action_delivery.target_effects.damage.amount = 32
new_cloud.particle_count = 6
new_cloud.particle_spread[1] = new_cloud.particle_spread[1] * 0.5
new_cloud.particle_spread[2] = new_cloud.particle_spread[2] * 0.5
new_cloud.color = {0.9, 0.4, 0.0, 0.65}
new_cloud.duration = 60 * 60
new_cloud.created_effect = {}
for i = 1, 4 do
  table.insert(new_cloud.created_effect, {
    type = "cluster",
    cluster_count = 2,
    distance = 1.5,
    distance_deviation = 1.5,
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "create-smoke",
          show_in_tooltip = false,
          entity_name = "rainbow-mini-smoke-dummy-" .. i,
          initial_height = 0
        }
      }
    }
  })
  table.insert(new_cloud.created_effect, {
    type = "cluster",
    cluster_count = 2,
    distance = 3.6,
    distance_deviation = 0.8,
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "create-smoke",
          show_in_tooltip = false,
          entity_name = "rainbow-mini-smoke-dummy-" .. i,
          initial_height = 0
        }
      }
    }
  })
end
data:extend({new_cloud})


-- Варпониевый гиперкуб
if mods["space-age"] then
    table.insert(data.raw.technology["automation-3"].prerequisites, "warponium-hypercube")
    table.insert(data.raw.technology["effect-transmission"].prerequisites, "warponium-hypercube")
    table.insert(data.raw.technology["kovarex-enrichment-process"].prerequisites, "warponium-hypercube")
    table.insert(data.raw.technology["quantum-processor"].prerequisites, "warponium-hypercube")
    table.insert(data.raw.technology["wdm_warp_drive_tech-7"].prerequisites, "ancient-drill") 
    table.insert(data.raw.recipe["assembling-machine-3"].ingredients, {type = "item", name = "warponium-hypercube", amount = 1})
    table.insert(data.raw.recipe["beacon"].ingredients, {type = "item", name = "warponium-hypercube", amount = 1})
    table.insert(data.raw.recipe["atomic-bomb"].ingredients, {type = "item", name = "warponium-hypercube", amount = 10})

    table.insert(data.raw.recipe["foundry"].ingredients, {type = "item", name = "warponium-hypercube", amount = 5})
    table.insert(data.raw.recipe["electromagnetic-plant"].ingredients, {type = "item", name = "warponium-hypercube", amount = 5})
    table.insert(data.raw.recipe["cryogenic-plant"].ingredients, {type = "item", name = "warponium-hypercube", amount = 5})
    table.insert(data.raw.recipe["recycler"].ingredients, {type = "item", name = "warponium-hypercube", amount = 5})
    table.insert(data.raw.recipe["biochamber"].ingredients, {type = "item", name = "warponium-hypercube", amount = 5})
    table.insert(data.raw.recipe["quantum-processor"].ingredients, {type = "item", name = "warponium-hypercube", amount = 1})
else
    table.insert(data.raw.technology["automation-3"].prerequisites, "warponium-hypercube")
    table.insert(data.raw.technology["effect-transmission"].prerequisites, "warponium-hypercube")
    table.insert(data.raw.technology["kovarex-enrichment-process"].prerequisites, "warponium-hypercube")
    table.insert(data.raw.technology["automation-3"].prerequisites, "ancient-drill")   
    table.insert(data.raw.recipe["assembling-machine-3"].ingredients, {type = "item", name = "warponium-hypercube", amount = 2})
    table.insert(data.raw.recipe["beacon"].ingredients, {type = "item", name = "warponium-hypercube", amount = 1})
    table.insert(data.raw.recipe["atomic-bomb"].ingredients, {type = "item", name = "warponium-hypercube", amount = 10})
end

-- K2-SA Compability
if mods["Krastorio2"] or mods["Krastorio2-spaced-out"] then
    table.insert(data.raw.technology["kr-energy-control-unit"].prerequisites, "warponium-hypercube")
    table.insert(data.raw.technology["wdm_warponium_processing"].prerequisites, "steel-processing")
    table.insert(data.raw.recipe["kr-energy-control-unit"].ingredients, {type = "item", name = "warponium-hypercube", amount = 1})
    table.insert(data.raw.recipe["warponium-solar-panel"].ingredients, {type = "item", name = "kr-glass", amount = 30})
    table.insert(data.raw.recipe["emergency-return"].ingredients, {type = "item", name = "kr-glass", amount = 5})
    table.insert(data.raw.recipe["crystal-processing-t2"].results, {type = "item", name = "kr-imersium-plate", amount = 25})

    for _, ing in ipairs(data.raw["recipe"]["pamk3-esmk3"].ingredients) do
        if ing.name == "energy-shield-mk2-equipment" then
            ing.name = "kr-energy-shield-mk3-equipment"
            break
        end
    end
    table.insert(data.raw["recipe"]["pamk3-esmk3"].ingredients, {type = "item", name = "kr-ai-core", amount = 5})
    table.insert(data.raw["recipe"]["pamk3-esmk3"].ingredients, {type = "item", name = "kr-imersium-plate", amount = 10})
    table.insert(data.raw["recipe"]["pamk3-esmk3"].ingredients, {type = "item", name = "kr-energy-control-unit", amount = 50})
    table.insert(data.raw["technology"]["pamk3-esmk3"].prerequisites, "kr-energy-shield-mk3-equipment")
    table.insert(data.raw["technology"]["pamk3-esmk3"].prerequisites, "kr-ai-core")
    table.insert(data.raw["technology"]["pamk3-esmk3"].prerequisites, "kr-energy-control-unit")
    if data.raw["technology"]["kr-energy-shield-mk4-equipment"] then
        data.raw["technology"]["kr-energy-shield-mk4-equipment"].hidden = true
        data.raw["technology"]["kr-energy-shield-mk4-equipment"].enabled = false
    end
    table.insert(data.raw["recipe"]["pamk3-se"].ingredients, {type = "item", name = "kr-imersium-plate", amount = 50})
    for _, ing in ipairs(data.raw["recipe"]["exoskeleton-mk2-equipment"].ingredients) do
        if ing.name == "exoskeleton-equipment" then
            ing.name = "kr-advanced-exoskeleton-equipment"
            break
        end
    end
    table.insert(data.raw["technology"]["exoskeleton-mk2-equipment"].prerequisites, "kr-advanced-exoskeleton-equipment")
    table.insert(data.raw["recipe"]["pamk3-pdd"].ingredients, {type = "item", name = "kr-lithium-sulfur-battery", amount = 5})
    table.insert(data.raw["technology"]["pamk3-pdd"].prerequisites, "kr-lithium-sulfur-battery")
end

-- Bob's Power Compability
if mods["bobpower"] then
    table.insert(data.raw.technology["warponium-solar-panel"].prerequisites, "bob-solar-energy-3")
    table.insert(data.raw.recipe["warponium-solar-panel"].ingredients, {type = "item", name = "processing-unit", amount = 8})
end