local item_sounds = require("__base__.prototypes.item_sounds")

return {
    {
        type = "item",
        name = "wdm-ship-abilities-console",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/ship-abilities-console.png",
        icon_size = 64,
        subgroup = "circuit-network",
        order = "z[ship-abilities-console]-e[ship-abilities-console]",
        inventory_move_sound = item_sounds.electric_large_inventory_move,
        pick_sound = item_sounds.electric_large_inventory_pickup,
        drop_sound = item_sounds.electric_large_inventory_move,
        place_result = "wdm-ship-abilities-console",
        stack_size = 1,
        weight = 50 * kg
    }
}