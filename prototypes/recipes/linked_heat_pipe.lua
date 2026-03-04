return {
    {
        type = "recipe",
        name = "linked-heat-pipe-1",
        enabled = false,
        energy_required = 50,
        ingredients = {
            {type = "item", name = "electronic-circuit", amount = 50},         
            {type = "item", name = "selector-combinator", amount = 20},
            {type = "item", name = "heat-pipe", amount = 10}, 
            {type = "item", name = "engine-unit", amount = 10}
        },
        results = {
            {type = "item", name = "linked-heat-pipe-1", amount = 1}
        }
    },
    {
        type = "recipe",
        name = "linked-heat-pipe-2",
        enabled = false,
        energy_required = 50,
        ingredients = {
            {type = "item", name = "linked-heat-pipe-1", amount = 1},
            {type = "item", name = "warponium-plate", amount = 10},
            {type = "item", name = "battery", amount = 10}
        },
        results = {
            {type = "item", name = "linked-heat-pipe-2", amount = 1}
        }
    },
    {
        type = "recipe",
        name = "linked-heat-pipe-3",
        enabled = false,
        energy_required = 50,
        ingredients = {
            {type = "item", name = "linked-heat-pipe-2", amount = 1},
            {type = "item", name = "warponium-plate", amount = 10},
            {type = "item", name = "electric-engine-unit", amount = 10},
            {type = "item", name = "advanced-circuit", amount = 15},
            {type = "item", name = "accumulator", amount = 15}

        },
        results = {
            {type = "item", name = "linked-heat-pipe-3", amount = 1}
        }
    },
    {
        type = "recipe",
        name = "linked-heat-pipe-4",
        enabled = false,
        energy_required = 50,
        ingredients = {
            {type = "item", name = "linked-heat-pipe-3", amount = 1},
            {type = "item", name = "low-density-structure", amount = 5},
            {type = "item", name = "processing-unit", amount = 10},
            {type = "item", name = "warponium-plate", amount = 10}
        },
        results = {
            {type = "item", name = "linked-heat-pipe-4", amount = 1}
        }
    }
}