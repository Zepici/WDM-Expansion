local item_sounds = require("__base__.prototypes.item_sounds")

return {
    {
        type = "item",
        name = "conversion-plant",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/entity/conversion-plant/conversion-plant-icon.png",
        icon_size = 64,
        subgroup = "production-machine",
        order = "c[conversion-plant]",
        inventory_move_sound = item_sounds.electric_large_inventory_move,
        pick_sound = item_sounds.electric_large_inventory_pickup,
        drop_sound = item_sounds.electric_large_inventory_move,
        place_result = "conversion-plant",
        stack_size = 20,
        weight = 20 * kg
    }
}
