return {
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
        minable = {mining_time = 0.5, result = "linked-heat-pipe-1"}
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
        minable = {mining_time = 0.5, result = "linked-heat-pipe-2"},
        pictures = {
            single = {
                layers = {
                    {
                        filename = "__base__/graphics/entity/heat-pipe/heat-pipe-straight-vertical.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        hr_version = {
                            filename = "__base__/graphics/entity/heat-pipe/hr-heat-pipe-straight-vertical.png",
                            priority = "extra-high",
                            width = 256,
                            height = 256,
                            scale = 0.5
                        },
                        tint = {r = 0.3, g = 0.7, b = 1.0, a = 1.0}
                    }
                }
            }
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
        minable = {mining_time = 0.5, result = "linked-heat-pipe-3"},
        pictures = {
            single = {
                layers = {
                    {
                        filename = "__base__/graphics/entity/heat-pipe/heat-pipe-straight-vertical.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        hr_version = {
                            filename = "__base__/graphics/entity/heat-pipe/hr-heat-pipe-straight-vertical.png",
                            priority = "extra-high",
                            width = 256,
                            height = 256,
                            scale = 0.5
                        },
                        tint = {r = 0.3, g = 1.0, b = 0.3, a = 1.0}
                    }
                }
            }
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
        minable = {mining_time = 0.5, result = "linked-heat-pipe-4"},
        pictures = {
            single = {
                layers = {
                    {
                        filename = "__base__/graphics/entity/heat-pipe/heat-pipe-straight-vertical.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        hr_version = {
                            filename = "__base__/graphics/entity/heat-pipe/hr-heat-pipe-straight-vertical.png",
                            priority = "extra-high",
                            width = 256,
                            height = 256,
                            scale = 0.5
                        },
                        tint = {r = 1.0, g = 0.3, b = 0.3, a = 1.0}
                    }
                }
            }
        }
    }
}