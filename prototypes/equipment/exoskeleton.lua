return {
    {
        type = "movement-bonus-equipment",
        name = "exoskeleton-mk2-equipment",
        sprite = {
            filename = "__Warp-Drive-Machine-Expansion__/graphics/equipment/equipment-exoskeleton-mk2-equipment.png",
            width = 128,
            height = 256
        },
        shape = {
            width = 2,
            height = 4,
            type = "full"
        },
        energy_source = {
            type = "electric",
            usage_priority = "primary-input"
        },
        energy_consumption = "340kW",
        movement_bonus = 0.5,
        categories = {"armor"}
    }
}
