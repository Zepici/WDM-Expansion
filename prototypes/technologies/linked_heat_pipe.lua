return {
    {
        type = "technology",
        name = "linked-heat-pipe-1",
        localised_name = {"", {"technology-name.linked-heat-pipe"}, " 1"},
        localised_description = {"technology-description.linked-heat-pipe"},
        icons = {
            {
                icon = "__base__/graphics/icons/heat-pipe.png",
                icon_size = 64
            },
            {
                icon = "__base__/graphics/icons/signal/signal_1.png",
                icon_size = 64,
                scale = 1,
                shift = {64, -64},
                priority = "medium"
            }
        },
        prerequisites = { "nuclear-power", "wdm-storage-room-1", "wdm_ship_power_tech-1", "advanced-combinators" },
        effects = {
            { type = "unlock-recipe", recipe = "linked-heat-pipe-1" }
        },
        unit = {
            count = 60,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 20
        },
        order = "z[heat-pipe]-l[linked-heat-pipe]1"
    },
    {
        type = "technology",
        name = "linked-heat-pipe-2",
        localised_name = {"", {"technology-name.linked-heat-pipe"}, " 2"},
        localised_description = {"technology-description.linked-heat-pipe"},
        icons = {
            {
                icon = "__base__/graphics/icons/heat-pipe.png",
                icon_size = 64
            },
            {
                icon = "__base__/graphics/icons/signal/signal_2.png",
                icon_size = 64,
                scale = 1,
                shift = {64, -64},
                priority = "medium",
                tint = {r = 0.3, g = 0.7, b = 1.0, a = 1.0}
            }
        },
        prerequisites = { "linked-heat-pipe-1", "wdm_ship_power_tech-2", "wdm_warponium_processing" },
        effects = {
            { type = "unlock-recipe", recipe = "linked-heat-pipe-2" }
        },
        unit = {
            count = 120,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"military-science-pack", 1}
            },
            time = 22
        },
        order = "z[heat-pipe]-l[linked-heat-pipe]2"
    },
    {
        type = "technology",
        name = "linked-heat-pipe-3",
        localised_name = {"", {"technology-name.linked-heat-pipe"}, " 3"},
        localised_description = {"technology-description.linked-heat-pipe"},
        icons = {
            {
                icon = "__base__/graphics/icons/heat-pipe.png",
                icon_size = 64
            },
            {
                icon = "__base__/graphics/icons/signal/signal_3.png",
                icon_size = 64,
                scale = 1,
                shift = {64, -64},
                priority = "medium",
                tint = {r = 0.3, g = 1.0, b = 0.3, a = 1.0}
            }
        },
        prerequisites = { "linked-heat-pipe-2", "production-science-pack", "wdm_ship_power_tech-3", "electric-engine" },
        effects = {
            { type = "unlock-recipe", recipe = "linked-heat-pipe-3" }
        },
        unit = {
            count = 180,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"military-science-pack", 1},
                {"production-science-pack", 1}
            },
            time = 24
        },
        order = "z[heat-pipe]-l[linked-heat-pipe]3"
    },
    {
        type = "technology",
        name = "linked-heat-pipe-4",
        localised_name = {"", {"technology-name.linked-heat-pipe"}, " 4"},
        localised_description = {"technology-description.linked-heat-pipe"},
        icons = {
            {
                icon = "__base__/graphics/icons/heat-pipe.png",
                icon_size = 64
            },
            {
                icon = "__base__/graphics/icons/signal/signal_4.png",
                icon_size = 64,
                scale = 1,
                shift = {64, -64},
                priority = "medium",
                tint = {r = 1.0, g = 0.3, b = 0.3, a = 1.0}
            }
        },
        prerequisites = { "linked-heat-pipe-3", "wdm_ship_power_tech-4" },
        effects = {
            { type = "unlock-recipe", recipe = "linked-heat-pipe-4" }
        },
        unit = {
            count = 240,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"military-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1}
            },
            time = 26
        },
        order = "z[heat-pipe]-l[linked-heat-pipe]4"
    }
}