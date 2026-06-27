-- Базовые технологии
local technologies = {
  {
    type = "technology",
    name = "pamk3-esmk3",
    icon = "__Warp-Drive-Machine-Expansion__/graphics/pamk3/technology/pamk3-esmk3.png",
    icons = util.technology_icon_constant_equipment("__Warp-Drive-Machine-Expansion__/graphics/pamk3/technology/pamk3-esmk3.png"),
    icon_size = 256,
    prerequisites = {"energy-shield-mk2-equipment", "power-armor-mk2",
  },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "pamk3-esmk3"
      }
    },
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 45
    },
    order = "g-e-d"
  },
  {
    type = "technology",
    name = "pamk3-se",
    icon = "__Warp-Drive-Machine-Expansion__/graphics/pamk3/technology/pamk3-se.png",
    icons = util.technology_icon_constant_equipment("__Warp-Drive-Machine-Expansion__/graphics/pamk3/technology/pamk3-se.png"),
    icon_size = 256,
    prerequisites = {"pamk3-esmk3", "pamk3-battmk3", "fission-reactor-equipment", "power-armor-mk2", "space-science-pack"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "pamk3-se"
      },
      {
        type = "unlock-recipe",
        recipe = "pamk3-inff"
      }
    },
    unit =
    {
      count = 10000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 120
    },
    order = "g-l"
  },
  {
    type = "technology",
    name = "pamk3-pdd",
    icons = util.technology_icon_constant_equipment("__base__/graphics/technology/discharge-defense-equipment.png"),
    prerequisites = {"discharge-defense-equipment", "military-4", "power-armor-mk2"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "pamk3-pdd"
      }
    },
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    }
  }
}

-- Space Age модификации
if mods["space-age"] then
  for _, t in ipairs(technologies) do
    if t.name == "pamk3-se" then
      t.prerequisites = {"pamk3-esmk3", "fusion-reactor-equipment", "battery-mk3-equipment"}
      t.unit.count = 1000
      t.unit.ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"cryogenic-science-pack", 1}
      }
    end
    if t.name == "pamk3-esmk3" then
      t.prerequisites = {"energy-shield-mk2-equipment", "power-armor-mk2", "metallurgic-science-pack"}
      t.unit.count = 750
      t.unit.ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"electromagnetic-science-pack", 1}
      }
    end
  end
end

return technologies