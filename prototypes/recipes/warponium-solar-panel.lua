if mods["Krastorio2"] or mods["Krastorio2-spaced-out"] then
    return {
        {
            type = "recipe",
            name = "warponium-solar-panel",
            energy_required = 15,
            enabled = false,
            ingredients = {
                {type = "item", name = "steel-plate", amount = 7},
                {type = "item", name = "advanced-circuit", amount = 20},
                {type = "item", name = "copper-plate", amount = 7},
                {type = "item", name = "warponium-plate", amount = 70}
            },
            results = {
                {type = "item", name = "warponium-solar-panel", amount = 1}
            }
        }
    }
else
    return {
        {
            type = "recipe",
            name = "warponium-solar-panel",
            energy_required = 15,
            enabled = false,
            ingredients = {
                {type = "item", name = "steel-plate", amount = 7},
                {type = "item", name = "advanced-circuit", amount = 20},
                {type = "item", name = "copper-plate", amount = 7},
                {type = "item", name = "warponium-plate", amount = 15}
            },
            results = {
                {type = "item", name = "warponium-solar-panel", amount = 1}
            }
        }
    }
end
