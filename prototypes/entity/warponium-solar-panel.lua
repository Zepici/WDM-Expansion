local hit_effects = require("__base__.prototypes.entity.hit-effects")

return {
    {
        type = "corpse",
        name = "warponium-solar-panel-remnants",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/warponium-solar-panel-icon.png",
        icon_size = 64,
        flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
        subgroup = "energy-remnants",
        order = "a-k-a",
        selection_box = {{-2, -1.5}, {2, 2.5}},
        tile_width = 3,
        tile_height = 5,
        selectable_in_game = false,
        dying_speed = 0.02,
        time_before_removed = 60 * 60,
        final_render_layer = "remnants",
        remove_on_tile_placement = false,
        random_corpse_variation = true,
        animation = {
            {
                layers = {
                    {
                        filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/warponium-solar-panel/warponium-solar-panel-rem_1.png",
                        height = 512,
                        width = 512,
                        line_length = 4,
                        frame_count = 20,
                        shift = util.by_pixel(0, 32),
                        scale = 0.5,
                        tint = {r = 0.85, g = 0.2, b = 0.6, a = 1}     
                    },
                    {
                        filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/warponium-solar-panel/warponium-solar-panel-remsh_1.png",
                        height = 512,
                        width = 512,
                        line_length = 4,
                        frame_count = 20,
                        scale = 0.5,
                        shift = util.by_pixel(32, 32),
                        draw_as_shadow = true
                    }
                }
            }
        }
    },
    {
        type = "solar-panel",
        name = "warponium-solar-panel",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/warponium-solar-panel-icon.png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.1, result = "warponium-solar-panel"},
        fast_replaceable_group = "solar-panel",
        max_health = 400,
        corpse = "warponium-solar-panel-remnants",
        dying_explosion = "solar-panel-explosion",
        collision_box = {{-1.9, -1.9}, {1.9, 1.9}},
        selection_box = {{-2, -2}, {2, 2}},
        build_grid_size = 1,
        damaged_trigger_effect = hit_effects.entity(),
        performance_at_night = 0.1,
        energy_source = {
            type = "electric",
            usage_priority = "solar"
        },
        picture = {
            layers = {
                {
                    filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/warponium-solar-panel/warponium-solar-panel.png",
                    priority = "high",
                    render_layer = "object",
                    width = 352,
                    height = 352,
                    shift = util.by_pixel(0, 2),
                    scale = 0.5,
                    tint = {r = 0.85, g = 0.2, b = 0.6, a = 1}
                },
                {
                    filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/warponium-solar-panel/warponium-solar-panel_mask.png",
                    priority = "high",
                    render_layer = "object",
                    width = 352,
                    height = 352,
                    shift = util.by_pixel(0, 2),
                    scale = 0.5
                },
                {
                    filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/warponium-solar-panel/warponium-solar-panel_sh.png",
                    priority = "high",
                    render_layer = "object",
                    width = 448,
                    height = 320,
                    shift = util.by_pixel(32, 2),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },
        impact_category = "glass",
        production = "240kW"
    }
}
