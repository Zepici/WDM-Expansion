return {
    {
        type = "technology",
        name = "wdm-ship-abilities-console",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/ship-abilities-console.png",
        icon_size = 64,
        effects = {
            { type = "unlock-recipe", recipe = "wdm-ship-abilities-console" },
            { type = "unlock-recipe", recipe = "warponium-storage-tank" }
        },
        prerequisites = {"wdm_warponium_fuel", "wdm_warp_drive_tech-3"},
        unit = {
            count = 250,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 60
        },
        order = "d[wdm-ship-abilities-console]"
    },
    {
        type = "technology",
        name = "wdm-ship-ability-cryo-freeze",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/ability.png",
        icon_size = 256,
        effects = {},
        prerequisites = {"wdm-ship-abilities-console"},
        unit = {
            count = 60,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 15
        }
    },
    {
        type = "technology",
        name = "wdm-ship-ability-reactor-boost",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/ability.png",
        icon_size = 256,
        effects = {},
        prerequisites = {"nuclear-power", "wdm-ship-abilities-console", "wdm_warp_drive_tech-4"},
        unit = {
            count = 125,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 90
        }
    },
    {
        type = "technology",
        name = "wdm-ship-ability-ammo-distributor",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/ability.png",
        icon_size = 256,
        effects = {},
        prerequisites = {"wdm-ship-abilities-console", "military-science-pack"},
        unit = {
            count = 150,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1}
            },
            time = 30
        }
    },
    {
        type = "technology",
        name = "wdm-ship-ability-cloak",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/ability.png",
        icon_size = 256,
        effects = {},
        prerequisites = {"wdm-ship-abilities-console", "military-4", "wdm_warp_drive_tech-5"},
        unit = {
            count = 200,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"military-science-pack", 1},
                {"utility-science-pack", 1}   
            },
            time = 90
        }
    },
    {
        type = "technology",
        name = "wdm-ship-ability-resource-collector",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/ability.png",
        icon_size = 256,
        effects = {},
        prerequisites = {"wdm-ship-abilities-console", "production-science-pack", "wdm_warp_drive_tech-5"},
        unit = {
            count = 200,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1}                
            },
            time = 60
        }
    }
--[[
    {
        type = "technology",
        name = "wdm-ship-ability-waste-recycler",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/warponium-solar-panel_tech.png",
        icon_size = 256,
        effects = {},
        prerequisites = {"logistics", "automation-science-pack"},
        unit = {
            count = 80,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 30
        }
    }
]]
}