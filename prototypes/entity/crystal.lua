return {
  {
    type = "simple-entity",
    name = "crystal",
    icons = {{icon = "__Warp-Drive-Machine-Expansion__/graphics/entity/crystal.png", tint = {r=1, g=0.2, b=0.6, a=1}, icon_size = 32}},
    flags = {"placeable-player", "player-creation"},
    minable = { mining_time = 1.5, result = "crystal" },
    max_health = 500,
    create_ghost_on_death  = false,
    is_military_target = false,
    alert_when_damaged = false,
    corpse = "small-remnants",
    collision_box = {{-0.8, -0.8 }, {0.8, 0.8}},
    selection_box = {{-1, -1}, {1, 1}},
    animations = {
      filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/crystal.png",
      tint = {r=1, g=0.2, b=0.6, a=1},
      priority = "low",
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
  }
}