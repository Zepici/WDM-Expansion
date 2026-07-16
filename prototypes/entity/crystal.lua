return {
  {
    type = "simple-entity",
    name = "entity-crystal",
    icons = {{icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/crystal.png", tint = {r=1, g=0.2, b=0.6, a=1}, icon_size = 64}},
    flags = {"placeable-player", "player-creation"},
    minable = { mining_time = 3.5, result = "crystal", amount = 1 },
    max_health = 2500,
    map_color = {r=1, g=0.2, b=0.6, a=0.8},
    is_military_target = false,
    corpse = "small-remnants",
    collision_box = {{-0.8, -0.8 }, {0.8, 0.8}},
    selection_box = {{-1, -1}, {1, 1}},
    animations = {
      filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/crystal.png",
      tint = {r=1, g=0.2, b=0.6, a=1},
      priority = "medium",
      width = 128,
      height = 128,
      scale = 1,
      apply_projection = false,
      frame_count = 32,
      line_length = 8,
      animation_speed = 0.3,
      shift = {0.65, 0}
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    radius_minimap_visualisation_color = {r=1, g=0.2, b=0.6, a=1}
  },
  {
    type = "simple-entity",
    name = "big-crystal",
    icons = {{icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/charged-crystal.png", tint = {r=1, g=0.2, b=0.6, a=1}, icon_size = 64}},
    flags = {"placeable-player", "player-creation"},
    minable = {
        mining_time = 30,
        results = {
            {type = "item", name = "crystal", amount = 5},
            {type = "item", name = "charged-crystal", amount = 1, independent_probability = 0.2}
        }
    },
    max_health = 10000,
    collision_box = {{-2.5, -2.5}, {2.5, 2.5}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    impact_category = "tree",
    map_color = {r=1, g=0.2, b=0.6, a=0.8},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    animations = {
      filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/big-crystal.png",
      tint = {r=1, g=0.2, b=0.6, a=1},
      priority = "medium",
      width = 256,
      height = 256,
      scale = 1,
      apply_projection = false,
      frame_count = 32,
      line_length = 8,
      animation_speed = 0.28,
      shift = {0, 0}
    },
  }
}
