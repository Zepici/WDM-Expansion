return {
    {
        type = "technology",
        name = "cold-kovarex",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/cold-kovarex.png",
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "cold-kovarex"
            }
        },
        prerequisites = {"cb-cold-alien-tech", "wdm_warponium_fuel"},
        unit = {
            count = 1000,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 60
        },
        order = "c-e-a[cold-kovarex]"
    },
    {
        type = "technology",
        name = "wdm-coldjet-damage",
        icon = "__Cold_biters__/graphics/technology/cold_damage_tech.png",
        icon_size = 256,
        effects = {
            {
                type = "ammo-damage",
                ammo_category = "coldjet-ammo",
                modifier = 0.2
            }
        },
        prerequisites = {"cb-coldjet-ammo-damage-2"},
        unit = {
            count_formula = "1500 * L",
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"military-science-pack", 1},
                {"utility-science-pack", 1}
            },
            time = 30
        },
        max_level = "infinite",
        upgrade = true,
        order = "c-e-b[wdm-coldjet-damage]"
    }
}
