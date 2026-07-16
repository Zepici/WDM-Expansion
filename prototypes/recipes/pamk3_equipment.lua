-- Базовые рецепты
local recipes = {
  {
    type = "recipe",
    name = "pamk3-esmk3",
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "energy-shield-mk2-equipment", amount = 10 },
      { type = "item", name = "low-density-structure",       amount = 30 },
      { type = "item", name = "processing-unit",             amount = 50 },
      { type = "item", name = "warponium-plate",             amount = 50 }
    },
    results = { { type = "item", name = "pamk3-esmk3", amount = 1 } }
  },
  {
    type = "recipe",
    name = "pamk3-se",
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "steel-plate",               amount = 100 },
      { type = "item", name = "low-density-structure",     amount = 200 },
      { type = "item", name = "processing-unit",           amount = 100 },
      { type = "item", name = "fission-reactor-equipment", amount = 1 },
      { type = "item", name = "pamk3-esmk3",               amount = 5 },
      { type = "item", name = "warponium-hypercube",       amount = 20 }
    },
    results = { { type = "item", name = "pamk3-se", amount = 1 } }
  },
  {
    type = "recipe",
    name = "pamk3-inff",
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "pamk3-se", amount = 1 }
    },
    results = { { type = "item", name = "pamk3-inff", amount = 1 } }
  },
  {
    type = "recipe",
    name = "pamk3-pdd",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {type = "item", name = "discharge-defense-equipment", amount = 5 },
      {type = "item", name = "processing-unit", amount = 20},
      {type = "item", name = "warponium-plate", amount = 50}
    },
    results = {{type="item", name="pamk3-pdd", amount=1}}
  }
}

if mods["space-age"] then
  for _, r in ipairs(recipes) do
    if r.name == "pamk3-se" then
      r.ingredients = {
        { type = "item", name = "tungsten-plate",            amount = 200 },
        { type = "item", name = "carbon-fiber",              amount = 100 },
        { type = "item", name = "fusion-reactor-equipment",  amount = 1 },
        { type = "item", name = "battery-mk3-equipment",     amount = 5 },
        { type = "item", name = "pamk3-esmk3",               amount = 5 },
        { type = "item", name = "warponium-hypercube",       amount = 20 }
      }
    end
    if r.name == "pamk3-esmk3" then
      r.ingredients = {
        { type = "item", name = "processing-unit",             amount = 50 },
        { type = "item", name = "tungsten-carbide",            amount = 50 },
        { type = "item", name = "energy-shield-mk2-equipment", amount = 10 },
        { type = "item", name = "warponium-plate",             amount = 50 }
      }
    end
  end
end

return recipes