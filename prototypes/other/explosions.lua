return {
    {
        type = "explosion",
        name = "dark-explosion",
        life_time = 28, 
        animations = {{
        filename = "__Warp-Drive-Machine-Expansion__/graphics/dark-explosion.png",
        draw_as_glow = true,
        blend_mode = "additive",
        priority = "high",
        line_length = 7,
        width = 180,
        height = 180,
        frame_count = 14,
        animation_speed = 0.5,
        shift = util.by_pixel(2,0),
        scale = 0.6,
        usage = "explosion"
        }},
        sound = {
            {
            filename = "__base__/sound/fight/large-explosion-1.ogg",
            volume = 0.4
            }
        }
    }
}
