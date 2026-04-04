local recipes = {
    {
        type = "recipe",
        name = "kj_electric_laser_player",
        category = "advanced-crafting",
        enabled = false,
        energy_required = 35,
        ingredients = {
            {type = "fluid", name = "warponium-fluid", amount = 2000},
            { type = "item", name = "steel-plate", amount = 10 },
            { type = "item", name = "processing-unit",    amount = 20 },
            { type = "item", name = "battery", amount = 20 }
        },
        results = { { type = "item", name = "kj_electric_laser_player", amount = 1 }, },
        auto_recycle = false,
        order = "j",
    }    
}

if mods["space-age"] then
    recipes["kj_electric_laser_player"] = {
        type = "recipe",
        name = "kj_electric_laser_player",
        category = "advanced-crafting",
        enabled = false,
        energy_required = 35,
        ingredients = {
            {type = "fluid", name = "warponium-fluid", amount = 2000},
            { type = "item", name = "steel-plate", amount = 10 },
            { type = "item", name = "processing-unit",    amount = 20 },
            { type = "item", name = "battery", amount = 20 }
        },
        results = { { type = "item", name = "kj_electric_laser_player", amount = 1 }, },
        auto_recycle = false,
        order = "j",
    }  
end     

return recipes