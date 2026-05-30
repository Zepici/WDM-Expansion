return {
    {
        type = "technology",
        name = "warponium-hypercube",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/warponium-hypercube.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "warponium-hypercube"
            }
        },
        prerequisites = {"production-science-pack", "wdm_warponium_fuel"},
        unit = {
            count = 200,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1}
            },
            time = 60
        },
        order = "c-e-a[warponium-hypercube]"
    }
}