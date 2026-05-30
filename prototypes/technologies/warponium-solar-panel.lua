return {
    {
        type = "technology",
        name = "warponium-solar-panel",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/warponium-solar-panel_tech.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "warponium-solar-panel"
            }
        },
        prerequisites = {"electric-energy-distribution-2", "solar-energy", "wdm_warponium_processing", "wdm_warp_drive_tech-2"},
        unit = {
            count = 250,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 30
        },
        order = "c-e-a[warponium-solar-panel]"
    }
}
