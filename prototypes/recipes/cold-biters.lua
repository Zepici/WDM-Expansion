
return {
    {
        type = "recipe",
        name = "cold-kovarex",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/cold-kovarex.png",
        icon_size = 64,
        categories = {"warponium"},
        ingredients = {
            { type = "fluid", name = "cb_alien_cold_extract", amount = 500 },
            { type = "fluid", name = "warponium-fluid", amount = 50 },
            { type = "item", name = "cb_alien_cold_gland", amount = 40 }
        },
        results = {
            { type = "item", name = "cb_alien_cold_gland", amount = 51 }
        },
        enabled = false,
        energy_required = 120
    }
}

