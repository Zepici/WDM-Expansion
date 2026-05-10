local item_sounds = require("__base__.prototypes.item_sounds")

return {
    {
        type = "item",
        name = "solar-matrix",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/solar-matrix-icon.png",
        icon_size = 64,
        subgroup = "energy",
        order = "d[solar-panel]-b[solar-matrix]",
        inventory_move_sound = item_sounds.electric_large_inventory_move,
        pick_sound = item_sounds.electric_large_inventory_pickup,
        drop_sound = item_sounds.electric_large_inventory_move,
        place_result = "solar-matrix",
        stack_size = 50,
        weight = 20 * kg
    }
}
