return {
  {
    type = "storage-tank",
    name = "warponium-storage-tank",
    icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/warponium-storage-tank.png",
    icon_size = 32,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "warponium-storage-tank"},
    max_health = 1000,
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fluid_box = {
      volume = 2500,
      pipe_covers = pipecoverspictures(),
      pipe_connections = {
        { direction = defines.direction.north, position = {0, 0}, hide_connection_info = true },
        { direction = defines.direction.east, position = {0, 0}, hide_connection_info = true },
        { direction = defines.direction.south, position = {0, 0}, hide_connection_info = true },
        { direction = defines.direction.west, position = {0, 0}, hide_connection_info = true }
      }
    },
    window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
    pictures = {
      picture = {
        sheets = {
          {
            filename = "__Warp-Drive-Machine-Expansion__/graphics/entity/warponium-storage-tank.png",
            priority = "extra-high",
            frames = 1,
            width = 220,
            height = 220,
            shift = util.by_pixel(0, 0),
            scale = 0.2
          }
        }
      },
      window_background = {
        filename = "__base__/graphics/entity/storage-tank/window-background.png",
        priority = "extra-high",
        width = 1,
        height = 1,
        hr_version = {
          filename = "__base__/graphics/entity/storage-tank/hr-window-background.png",
          priority = "extra-high",
          width = 1,
          height = 1,
          scale = 0.5
        }
      },
      flow_sprite = {
        filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
        priority = "extra-high",
        width = 1,
        height = 1
      },
      gas_flow = {
        filename = "__base__/graphics/entity/pipe/steam.png",
        priority = "extra-high",
        line_length = 10,
        width = 1,
        height = 1,
        frame_count = 60,
        axially_symmetrical = false,
        direction_count = 1,
        animation_speed = 0.25,
        hr_version = {
          filename = "__base__/graphics/entity/pipe/hr-steam.png",
          priority = "extra-high",
          line_length = 10,
          width = 1,
          height = 1,
          frame_count = 60,
          axially_symmetrical = false,
          animation_speed = 0.25,
          direction_count = 1,
          scale = 0.5
        }
      }
    },
    flow_length_in_ticks = 360,
    vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound = {
      sound = {
        filename = "__base__/sound/storage-tank.ogg",
        volume = 0.8
      },
      match_volume_to_activity = true,
      apparent_volume = 1.5,
      max_sounds_per_type = 3
    },
    circuit_wire_connection_points = circuit_connector_definitions["storage-tank"].points,
    circuit_connector_sprites = circuit_connector_definitions["storage-tank"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
  }
}
