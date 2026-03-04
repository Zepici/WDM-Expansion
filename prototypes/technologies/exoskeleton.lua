return {
    {
        type = "technology",
        name = "exoskeleton-mk2-equipment",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/technology/tech-exoskeleton-mk2-equipment.png",
        icon_size = 256,
        prerequisites = { "exoskeleton-equipment", "low-density-structure", "utility-science-pack" },
        effects = {
            { type = "unlock-recipe", recipe = "exoskeleton-mk2-equipment" }
        },
        unit = {
            count = 150,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "chemical-science-pack", 1 },
                { "utility-science-pack", 1 }
            },
            time = 30
        }
    }
}
