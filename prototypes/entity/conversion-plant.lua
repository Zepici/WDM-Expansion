local assembler2pipepictures =
{
  north = util.sprite_load("__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-N",
  {
    priority = "extra-high",
    scale = 0.5,
  }),
  east = util.sprite_load("__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-E",
  {
    priority = "extra-high",
    scale = 0.5,
  }),
  south = util.sprite_load("__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-S",
  {
    priority = "extra-high",
    scale = 0.5,
  }),
  west = util.sprite_load("__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-W",
  {
    priority = "extra-high",
    scale = 0.5,
  }),
}

return {
    {
        type = "assembling-machine",
        name = "conversion-plant",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/entity/conversion-plant/conversion-plant-icon.png",
        icon_size = 64,
        flags = {"placeable-player", "player-creation"},
        minable = {mining_time = 1, result = "conversion-plant"},
        max_health = 350,
        corpse = "medium-remnants",
        collision_box = {{-1.8, -1.8}, {1.8, 1.8}},
        selection_box = {{-2.0, -2.0}, {2.0, 2.0}},
        drawing_box = {{-2.0, -2.5}, {2.0, 2.0}},
        crafting_categories = {"warponium"},
        crafting_speed = 1,
        module_slots = 3,
        allowed_effects = {"speed", "consumption", "quality"},
        energy_usage = "2.9MW",
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = {pollution = 10}
        },
        fluid_boxes = {
            {
                production_type = "input",
                pipe_picture = assembler2pipepictures,
                pipe_covers = pipecoverspictures(),
                volume = 100,
                pipe_connections = {
                    {flow_direction = "input", direction = defines.direction.west, position = {-1.5, -0.5}}
                }
            },
            {
                production_type = "input",
                pipe_picture = assembler2pipepictures,
                pipe_covers = pipecoverspictures(),
                volume = 100,
                pipe_connections = {
                    {flow_direction = "input", direction = defines.direction.north, position = {0.5, -1.5}}
                }
            },
            {
                production_type = "output",
                pipe_picture = assembler2pipepictures,
                pipe_covers = pipecoverspictures(),
                volume = 100,
                pipe_connections = {
                    {flow_direction = "output", direction = defines.direction.east, position = {1.5, 0.5}}
                }
            },
                        {
                production_type = "output",
                pipe_picture = assembler2pipepictures,
                pipe_covers = pipecoverspictures(),
                volume = 100,
                pipe_connections = {
                    {flow_direction = "output", direction = defines.direction.south, position = {0.5, 1.5}}
                }
            }
        },
        graphics_set = {
            animation = {
                layers = {
                    {
                        filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/conversion-plant/conversion-plant-hr-animation-1.png",
                        width = 280,
                        height = 320,
                        frame_count = 60,
                        line_length = 8,
                        animation_speed = 0.8,
                        scale = 0.45
                    },
                    {
                        filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/conversion-plant/conversion-plant-hr-color1-1.png",
                        width = 280,
                        height = 320,
                        frame_count = 60,
                        line_length = 8,
                        animation_speed = 0.8,
                        scale = 0.45,
                        tint = {r = 0.94, g = 0.55, b = 0, a = 0.42}
                    },
                    {
                        filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/conversion-plant/conversion-plant-hr-color2-1.png",
                        width = 280,
                        height = 320,
                        frame_count = 60,
                        line_length = 8,
                        animation_speed = 0.8,
                        scale = 0.45,
                        tint = {r = 0.85, g = 0.2, b = 0.6, a = 1}
                    },
                    {
                        filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/conversion-plant/conversion-plant-hr-emission-1.png",
                        width = 280,
                        height = 320,
                        frame_count = 60,
                        line_length = 8,
                        animation_speed = 0.8,
                        blend_mode = "additive",
                        draw_as_glow = true,
                        scale = 0.45
                    },
                    {
                        filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/conversion-plant/conversion-plant-hr-shadow.png",
                        width = 700,
                        height = 500,
                        repeat_count = 60,
                        shift = util.by_pixel(25, 15),
                        draw_as_shadow = true,
                        scale = 0.45
                    }
                }
            }
        },
        working_sound = {
            sound = {filename = "__Warp-Drive-Machine-Expansion__/sounds/conversion-plant.ogg", volume = 1}
        },
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65}
    }
}