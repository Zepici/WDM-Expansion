return {
    {
        type = "technology",
        name = "emergency-return",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/emergency_recall.png",
        icon_size = 256,
        effects = {
            { type = "unlock-recipe", recipe = "emergency-return" }
        },
        prerequisites = {"chemical-science-pack", "wdm_warponium_processing", "battery"},  
        unit = {
            count = 50,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}       
            },
            time = 30
        }
    }
}