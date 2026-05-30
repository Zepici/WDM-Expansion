local item_sounds = require("__base__.prototypes.item_sounds")

return {
    {
        type = "item",
        name = "warponium-solar-panel",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/warponium-solar-panel-icon.png",
        icon_size = 64,
        subgroup = "energy",
        order = "d[solar-panel]-b[warponium-solar-panel]",
        inventory_move_sound = item_sounds.electric_large_inventory_move,
        pick_sound = item_sounds.electric_large_inventory_pickup,
        drop_sound = item_sounds.electric_large_inventory_move,
        place_result = "warponium-solar-panel",
        stack_size = 50,
        weight = 20 * kg
    }
}
