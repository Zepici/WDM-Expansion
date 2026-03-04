return {
    {
        type = "technology",
        name = "crystal-processing",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/crystal.png",
        icon_size = 256,
        effects = {
            { type = "unlock-recipe", recipe = "crystal-processing" }
        },
        prerequisites = {"logistic-science-pack", "wdm_warponium_processing"},  
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}     
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "crystal-processing-t2",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/crystal.png",
        icon_size = 256,
        effects = {
            { type = "unlock-recipe", recipe = "crystal-processing-t2" }
        },
        prerequisites = {"chemical-science-pack", "crystal-processing", "space-science-pack", "wdm_warp_drive_tech-4"},  
        unit = {
            count = 500,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"space-science-pack", 1}           
            },
            time = 60
        }
    }
}