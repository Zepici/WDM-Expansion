local function apply_tint(pictures, tint)
    if type(pictures) ~= "table" then return pictures end
    for _, v in pairs(pictures) do
        if type(v) == "table" then
            if v.layers then
                for _, layer in ipairs(v.layers) do
                    if type(layer) == "table" then
                        layer.tint = tint
                    end
                end
            end
            apply_tint(v, tint)
        end
    end
    return pictures
end

local heat_glow_states = {
    single = { empty = true },
    straight_vertical = { variations = 6 },
    straight_horizontal = { variations = 6 },
    corner_right_up = { name = "corner-up-right", variations = 6 },
    corner_left_up = { name = "corner-up-left", variations = 6 },
    corner_right_down = { name = "corner-down-right", variations = 6 },
    corner_left_down = { name = "corner-down-left", variations = 6 },
    t_up = {},
    t_down = {},
    t_right = {},
    t_left = {},
    cross = { name = "t" },
    ending_up = {},
    ending_down = {},
    ending_right = {},
    ending_left = {}
}

local pipes = {
    {
        _base = data.raw["heat-pipe"]["heat-pipe"],
        type = "heat-pipe",
        name = "linked-heat-pipe-1",
        localised_name = {"", {"entity-name.linked-heat-pipe"}, " 1"},
        localised_description = {"entity-description.linked-heat-pipe"},
        icons = {
            {
                icon = "__base__/graphics/icons/heat-pipe.png", 
                icon_size = 64, 
                priority = "medium"
            },
            {
                icon = "__base__/graphics/icons/signal/signal_1.png", 
                icon_size = 64, 
                priority = "medium", 
                scale = 0.25, 
                shift = {10, -10}
            }
        },
        minable = {mining_time = 0.5, result = "linked-heat-pipe-1"},
        heating_radius = 0,
        heat_buffer = {
            max_temperature = 1000
        }
    },
    {
        _base = data.raw["heat-pipe"]["heat-pipe"],
        type = "heat-pipe",
        name = "linked-heat-pipe-2",
        localised_name = {"", {"entity-name.linked-heat-pipe"}, " 2"},
        localised_description = {"entity-description.linked-heat-pipe"},
        icons = {
            {
                icon = "__base__/graphics/icons/heat-pipe.png", 
                icon_size = 64, 
                priority = "medium",
                tint = {r = 0.3, g = 0.7, b = 1.0, a = 1.0}
            },
            {
                icon = "__base__/graphics/icons/signal/signal_2.png", 
                icon_size = 64, 
                priority = "medium", 
                scale = 0.25, 
                shift = {10, -10}
            }
        },
        heat_glow_sprites = apply_tint(
            make_heat_pipe_pictures("__base__/graphics/entity/heat-pipe/", "heated", heat_glow_states, true),
            {r = 0.3, g = 0.5, b = 1.0, a = 0.7}
        ),
        minable = {mining_time = 0.5, result = "linked-heat-pipe-2"},
        heating_radius = 0,
        heat_buffer = {
            max_temperature = 1000
        }
    },
    {
        _base = data.raw["heat-pipe"]["heat-pipe"],
        type = "heat-pipe",
        name = "linked-heat-pipe-3",
        localised_name = {"", {"entity-name.linked-heat-pipe"}, " 3"},
        localised_description = {"entity-description.linked-heat-pipe"},
        icons = {
            {
                icon = "__base__/graphics/icons/heat-pipe.png", 
                icon_size = 64, 
                priority = "medium",
                tint = {r = 0.3, g = 1.0, b = 0.3, a = 1.0}
            },
            {
                icon = "__base__/graphics/icons/signal/signal_3.png", 
                icon_size = 64, 
                priority = "medium", 
                scale = 0.25, 
                shift = {10, -10}
            }
        },
        heat_glow_sprites = apply_tint(
            make_heat_pipe_pictures("__base__/graphics/entity/heat-pipe/", "heated", heat_glow_states, true),
            {r = 0.3, g = 1.0, b = 0.3, a = 0.5}
        ),
        minable = {mining_time = 0.5, result = "linked-heat-pipe-3"},
        heating_radius = 0,
        heat_buffer = {
            max_temperature = 1000
        }
    },
    {
        _base = data.raw["heat-pipe"]["heat-pipe"],
        type = "heat-pipe",
        name = "linked-heat-pipe-4",
        localised_name = {"", {"entity-name.linked-heat-pipe"}, " 4"},
        localised_description = {"entity-description.linked-heat-pipe"},
        icons = {
            {
                icon = "__base__/graphics/icons/heat-pipe.png", 
                icon_size = 64, 
                priority = "medium",
                tint = {r = 1.0, g = 0.3, b = 0.3, a = 1.0}
            },
            {
                icon = "__base__/graphics/icons/signal/signal_4.png", 
                icon_size = 64, 
                priority = "medium", 
                scale = 0.25, 
                shift = {10, -10}
            }
        },
        heat_glow_sprites = apply_tint(
            make_heat_pipe_pictures("__base__/graphics/entity/heat-pipe/", "heated", heat_glow_states, true),
            {r = 1.0, g = 0.3, b = 0.3, a = 0.5}
        ),
        minable = {mining_time = 0.5, result = "linked-heat-pipe-4"},
        heating_radius = 0,
        heat_buffer = {
            max_temperature = 1000
        }
    }
}

if mods["bobpower"] then
    pipes[1].heat_buffer.max_temperature = 750
    pipes[2].heat_buffer.max_temperature = 1000
    pipes[3].heat_buffer.max_temperature = 1250
    pipes[4].heat_buffer.max_temperature = 1500
end

return pipes