return {
    {
        type = "recipe",
        name = "crystal-processing",
        icons = {
            {
                icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/crystal.png",
                icon_size = 32,
                tint = {r=1, g=0.2, b=0.6, a=1}
            }
        },
        category = "chemistry",
        ingredients = {
            {type = "item", name = "crystal", amount = 1},
            {type = "fluid", name = "sulfuric-acid", amount = 500}
        },
        results = {
            {type = "item", name = "crystal", amount = 1, probability = 0.1},
            {type = "item", name = "uranium-235", amount = 1, probability = 0.1},
            {type = "item", name = "warponium-plate", amount = 10, probability = 0.5},
            {type = "item", name = "stone", amount = 200},
            {type = "item", name = "iron-plate", amount = 100},
            {type = "item", name = "copper-plate", amount = 100},
            {type = "item", name = "coal", amount = 100},            
            {type = "fluid", name = "warponium-fluid", amount = 100},
            {type = "fluid", name = "crude-oil", amount = 3500}
        },
        enabled = false,
        energy_required = 125
    },
    {
        type = "recipe",
        name = "crystal-processing-t2",
        icons = {
            {
                icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/crystal.png",
                icon_size = 32,
                tint = {r=1, g=0.2, b=0.6, a=1}
            }
        },
        category = "chemistry",
        ingredients = {
            {type = "item", name = "crystal", amount = 1},
            {type = "fluid", name = "sulfuric-acid", amount = 500}
        },
        results = {
            {type = "item", name = "crystal", amount = 1, probability = 0.5},
            {type = "item", name = "uranium-235", amount = 1, probability = 0.1},
            {type = "item", name = "warponium-plate", amount = 10, probability = 0.5},
            {type = "item", name = "stone", amount = 200},
            {type = "item", name = "iron-plate", amount = 100},
            {type = "item", name = "copper-plate", amount = 100},
            {type = "item", name = "coal", amount = 100}, 
            {type = "fluid", name = "warponium-fluid", amount = 300},
            {type = "fluid", name = "crude-oil", amount = 3500}
        },
        enabled = false,
        energy_required = 150
    }
}