-- Radio terminal
return {
    {
        type = "container",
        name = "wdm-ship-abilities-console",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/ship-abilities-console.png",
        icon_size = 64,
        minable = {mining_time = 10, result = "wdm-ship-abilities-console"},
        max_health = 1500,
        corpse = "ship-abilities-console-corpse",
        dying_explosion = data.raw["furnace"]["electric-furnace"].dying_explosion,
        inventory_size = 0,
        collision_box = {{-0.7, -1.2}, {0.7, 1.2}},
        selection_box = {{-0.95, -1.45}, {0.95, 1.45}},
        selection_priority = 90,
        flags = {"placeable-player", "player-creation", "not-rotatable", "not-blueprintable"},
        picture = {
        layers = {
            {
            filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/ship-abilities-console/ship-abilities-console-hr-animation-1.png",
            priority = "high",
            width = 160,
            height = 290,
            frame_count = 20,
            line_length = 8,
            shift = util.by_pixel(0, 0),
            scale = 0.5
            },
            {
            filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/ship-abilities-console/ship-abilities-console-hr-shadow.png",
            priority = "high",
            width = 400,
            height = 350,
            frame_count = 1,
            line_length = 1,
            repeat_count = 20,
            draw_as_shadow = true,
            shift = util.by_pixel(0, 0),
            scale = 0.5
            },
            {
            filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/ship-abilities-console/ship-abilities-console-hr-emission-1.png",
            priority = "high",
            width = 160,
            height = 290,
            frame_count = 20,
            line_length = 8,
            draw_as_glow = true,
            blend_mode = "additive",
            shift = util.by_pixel(0, 0),
            scale = 0.5
            }
        }
        },
        circuit_wire_connection_point = nil,
        circuit_connector_sprites = nil,
        circuit_wire_max_distance = 0
    }
}
