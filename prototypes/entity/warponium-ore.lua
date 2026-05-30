local resource_autoplace = require("resource-autoplace")

return {
--[[
    {
        type = "autoplace-control",
        name = "underground-warponium",
        richness = true,
        order = "z-w",
        category = "resource"
    },
]]
    {
        type = "resource",
        name = "underground-warponium",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/warponium-ore.png",
        icon_size = 64,
        flags = {"placeable-neutral"},
        map_color = {r=1, g=0.2, b=0.6, a=0.8},
        
        infinite = true,
        minimum = 5,
        normal = 300,
        infinite_depletion_amount = 2,
        category = "warponium-hard-solid",
        subgroup = "raw-resource",
        order = "w[warponium-ore]-b",
        minable = {
            mining_particle = "stone-particle",
            mining_time = 8,
            fluid_amount = 100,
            required_fluid = "steam",
            results = {
                {
                    type = "item",
                    name = "wdm-ore-warponium",
                    amount = 15
                }
            }
        },
        collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        autoplace = resource_autoplace.resource_autoplace_settings{
            name = "underground-warponium",
            order = "z",
            base_density = 10,
            base_spots_per_km2 = 2.5,
            has_fluid = false
        },
        stages = {
            sheet = {
                filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/warponium-ore/ore5.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                frame_count = 8,
                variation_count = 8,
                scale = 0.5,
            }
        },
        stages_effect = {
            sheets = {
                {
                    filename = "__base__/graphics/entity/uranium-ore/uranium-ore-glow.png",
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    frame_count = 8,
                    variation_count = 8,
                    scale = 0.5,
                    blend_mode = "additive",
                    flags = {"light"},
                    tint = {r=0.88, g=0.07, b=0.37, a=1}
                }
            }
        },
        effect_animation_period = 5,
        effect_animation_period_deviation = 1,
        effect_darkness_multiplier = 3.6,
        min_effect_alpha = 0.2,
        max_effect_alpha = 0.8,
        stage_counts = {10000, 6330, 3670, 1930, 870, 270, 100, 50},
    }
}