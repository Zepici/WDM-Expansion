require "util"

if not mods["space-age"] then return {} end

local beam_blend_mode = "additive"
local beam_non_light_flags = { "trilinear-filtering" }
-- Рубиновый оттенок для стартового луча
local ruby_tint = { r = 0.9, g = 0.15, b = 0.2, a = 1 }

local function wdm_get_beam_sprite(token, beam_tint)
  return
  {
    util.sprite_load("__space-age__/graphics/entity/beam/tesla-body-"..token.."",
    {
      frame_count = 20,
      repeat_count = 4,
      draw_as_glow = true,
      animation_speed = 0.5,
      scale = 0.8,
      tint = beam_tint,
      blend_mode = beam_blend_mode
    }),
    util.sprite_load("__space-age__/graphics/entity/beam/lightning-loop-"..token.."",
    {
      frame_count = 80,
      draw_as_glow = true,
      animation_speed = 0.5,
      scale = 0.8,
      tint = beam_tint,
      blend_mode = beam_blend_mode
    })
  }
end

local function wdm_get_chain_sprite(token, beam_tint)
  return
  {
    util.sprite_load("__space-age__/graphics/entity/beam/chain-body-0",
    {
      frame_count = 1,
      repeat_count = 40,
      draw_as_glow = true,
      animation_speed = 0.5,
      scale = 0.8,
      tint = beam_tint,
      blend_mode = beam_blend_mode
    }),
    util.sprite_load("__space-age__/graphics/entity/beam/chain-body-"..token.."",
    {
      frame_count = 40,
      draw_as_glow = true,
      animation_speed = 0.5,
      scale = 0.8,
      tint = beam_tint,
      blend_mode = beam_blend_mode
    })
  }
end

local function wdm_make_tesla_electric_beam_graphics(blend_mode, beam_flags, beam_tint, light_tint, base_graphics_set)
  beam_tint = beam_tint or ruby_tint
  local graphics_set = base_graphics_set or {}
  graphics_set.beam =
  {
    start = util.sprite_load("__space-age__/graphics/entity/beam/tesla-beam-START",
    {
      flags = beam_flags or beam_non_light_flags,
      frame_count = 20,
      draw_as_glow = true,
      tint = beam_tint,
      animation_speed = 0.5,
      scale = 0.8
    }),

    ending = util.sprite_load("__space-age__/graphics/entity/beam/tesla-beam-END",
    {
      flags = beam_flags or beam_non_light_flags,
      frame_count = 20,
      draw_as_glow = true,
      tint = beam_tint,
      animation_speed = 0.5,
      scale = 0.8
    }),

    head = util.sprite_load("__space-age__/graphics/entity/beam/tesla-head",
    {
      flags = beam_flags or beam_non_light_flags,
      frame_count = 20,
      draw_as_glow = true,
      animation_speed = 0.5,
      scale = 0.8,
      tint = beam_tint,
      blend_mode = blend_mode or beam_blend_mode
    }),

    tail = util.sprite_load("__space-age__/graphics/entity/beam/tesla-tail",
    {
      flags = beam_flags or beam_non_light_flags,
      frame_count = 20,
      draw_as_glow = true,
      animation_speed = 0.5,
      scale = 0.8,
      tint = beam_tint,
      blend_mode = blend_mode or beam_blend_mode
    }),

    body =
    {
      {layers=wdm_get_beam_sprite('1', beam_tint)},
      {layers=wdm_get_beam_sprite('2', beam_tint)},
      {layers=wdm_get_beam_sprite('3', beam_tint)},
      {layers=wdm_get_beam_sprite('4', beam_tint)},
      {layers=wdm_get_beam_sprite('5', beam_tint)},
      {layers=wdm_get_beam_sprite('6', beam_tint)},
    }
  }

  graphics_set.ground =
  {
    head =
    {
      filename = "__base__/graphics/entity/laser-turret/laser-ground-light-head.png",
      draw_as_light = true,
      flags = {"light"},
      line_length = 1,
      width = 256,
      height = 256,
      scale = 0.5,
      shift = util.by_pixel(-32, 0),
      animation_speed = 0.5,
      tint = light_tint or {0.05, 0.5, 0.5}
    },
    tail =
    {
      filename = "__base__/graphics/entity/laser-turret/laser-ground-light-tail.png",
      draw_as_light = true,
      flags = {"light"},
      line_length = 1,
      width = 256,
      height = 256,
      scale = 0.5,
      shift = util.by_pixel(32, 0),
      animation_speed = 0.5,
      tint = light_tint or {0.05, 0.5, 0.5}
    },
    body =
    {
      filename = "__base__/graphics/entity/laser-turret/laser-ground-light-body.png",
      draw_as_light = true,
      flags = {"light"},
      line_length = 1,
      width = 64,
      height = 256,
      scale = 0.5,
      animation_speed = 0.5,
      tint = light_tint or {0.05, 0.5, 0.5}
    }
  }

  return graphics_set
end

local function wdm_make_tesla_electric_beam_chain_graphics(blend_mode, beam_flags, beam_tint, light_tint, base_graphics_set)
  beam_tint = beam_tint or nil
  light_tint = light_tint or {0.05, 0.5, 0.5}
  local graphics_set = base_graphics_set or {}
  graphics_set.beam =
  {
    start = util.sprite_load("__space-age__/graphics/entity/beam/chain-beam-START",
    {
      flags = beam_flags or beam_non_light_flags,
      frame_count = 20,
      draw_as_glow = true,
      tint = beam_tint,
      animation_speed = 0.5,
      scale = 0.8
    }),

    ending = util.sprite_load("__space-age__/graphics/entity/beam/chain-beam-END",
    {
      flags = beam_flags or beam_non_light_flags,
      frame_count = 20,
      draw_as_glow = true,
      tint = beam_tint,
      animation_speed = 0.5,
      scale = 0.8
    }),

    head = {layers=wdm_get_chain_sprite('1', beam_tint)},

    tail = {layers=wdm_get_chain_sprite('6', beam_tint)},

    body =
    {
      {layers=wdm_get_chain_sprite('1', beam_tint)},
      {layers=wdm_get_chain_sprite('2', beam_tint)},
      {layers=wdm_get_chain_sprite('3', beam_tint)},
      {layers=wdm_get_chain_sprite('4', beam_tint)},
      {layers=wdm_get_chain_sprite('5', beam_tint)},
      {layers=wdm_get_chain_sprite('6', beam_tint)},
    }
  }

  graphics_set.ground =
  {
    head =
    {
      filename = "__base__/graphics/entity/laser-turret/laser-ground-light-head.png",
      draw_as_light = true,
      flags = {"light"},
      line_length = 1,
      width = 256,
      height = 256,
      scale = 0.5,
      shift = util.by_pixel(-32, 0),
      animation_speed = 0.5,
      tint = light_tint
    },
    tail =
    {
      filename = "__base__/graphics/entity/laser-turret/laser-ground-light-tail.png",
      draw_as_light = true,
      flags = {"light"},
      line_length = 1,
      width = 256,
      height = 256,
      scale = 0.5,
      shift = util.by_pixel(32, 0),
      animation_speed = 0.5,
      tint = light_tint
    },
    body =
    {
      filename = "__base__/graphics/entity/laser-turret/laser-ground-light-body.png",
      draw_as_light = true,
      flags = {"light"},
      line_length = 1,
      width = 64,
      height = 256,
      scale = 0.5,
      animation_speed = 0.5,
      tint = light_tint
    }
  }

  return graphics_set
end

local function wdm_make_tesla_beam(name, sound, damage)
  return
  {
    name = name,
    type = "beam",
    flags = {"not-on-map"},
    hidden = true,
    width = 1.0,
    damage_interval = 20,
    random_target_offset = true,
    target_offset = {0, 0},
    action_triggered_automatically = false,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = damage, type = "warponium-damage"}
          },
          {
            type = "push-back",
            distance = 200
          },
          {
            type = "create-sticker",
            sticker = "tesla-turret-stun"
          },
          {
            type = "create-sticker",
            sticker = "tesla-turret-slow"
          }
        }
      }
    },
    graphics_set = wdm_make_tesla_electric_beam_graphics(beam_blend_mode, beam_non_light_flags, nil, ruby_tint,
                                                     {
                                                       desired_segment_length = 1,
                                                       randomize_animation_per_segment = true
                                                     }),

    working_sound =
    sound and {
      sound = {category = "weapon", filename = "__space-age__/sound/entity/tesla-turret/tesla-turret-beam.ogg", volume = 1.0},
      max_sounds_per_prototype = 4
    } or nil,
  }
end

local function wdm_make_tesla_beam_chain(name, sound, damage, use_ruby)
  return
  {
    name = name,
    type = "beam",
    flags = {"not-on-map"},
    hidden = true,
    width = 1.0,
    damage_interval = 20,
    random_target_offset = true,
    target_offset = {0, 0},
    action_triggered_automatically = false,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = damage, type = "warponium-damage"}
          },
          {
            type = "push-back",
            distance = 0.5
          },
          {
            type = "create-sticker",
            sticker = "tesla-turret-stun"
          },
          {
            type = "create-sticker",
            sticker = "tesla-turret-slow"
          }
        }
      }
    },
    graphics_set = wdm_make_tesla_electric_beam_chain_graphics(beam_blend_mode, beam_non_light_flags, use_ruby and ruby_tint or nil, use_ruby and ruby_tint or nil,
                                                     {
                                                       desired_segment_length = 1,
                                                       randomize_animation_per_segment = true
                                                     }),

    working_sound =
    sound and {
      sound = {category = "weapon", filename = "__space-age__/sound/entity/tesla-turret/tesla-turret-chain-beam.ogg", volume = 0.8},
      max_sounds_per_prototype = 4
    } or nil,
  }
end

local function wdm_make_tesla_chain_lightning_chain(name, base_beam_name, ruby_beam_name, max_jumps, jump_range, fork_chance, fork_chance_per_quality, beam_duration)
  return {
    name = name,
    type = "chain-active-trigger",
    max_jumps = max_jumps,
    max_range_per_jump = jump_range,
    jump_delay_ticks = 6,
    fork_chance = fork_chance,
    fork_chance_increase_per_quality_level = fork_chance_per_quality,
    action =
    {
      -- Базовая молния: всегда, именно она несёт урон
      {
        type = "direct",
        probability = 1,
        action_delivery =
        {
          type = "beam",
          beam = base_beam_name,
          max_length = jump_range + 0.5,
          duration = beam_duration,
          add_to_shooter = false,
          destroy_with_source_or_target = false,
          source_offset = {0, 0}, -- should match beam's target_offset
        },
      },
      -- Рубиновая молния: 50% шанс, чисто визуальная (без урона),
      -- чтобы цепные молнии перемежались цветами
      {
        type = "direct",
        probability = 0.5,
        action_delivery =
        {
          type = "beam",
          beam = ruby_beam_name,
          max_length = jump_range + 0.5,
          duration = beam_duration,
          add_to_shooter = false,
          destroy_with_source_or_target = false,
          source_offset = {0, 0}, -- should match beam's target_offset
        },
      },
    },
  }
end

local overwpower_tesla_beams =
{
  wdm_make_tesla_beam("wdm-overpower-tesla-gun-beam-start", true, 20000),
  wdm_make_tesla_beam_chain("wdm-overpower-tesla-gun-beam-bounce", true, 10000),
  -- Рубиновая цепная молния: только визуал, без урона
  wdm_make_tesla_beam_chain("wdm-overpower-tesla-gun-beam-bounce-ruby", true, 0, true),
}

local overwpower_tesla_chain =
{
  wdm_make_tesla_chain_lightning_chain("wdm-overpower-tesla-gun-chain", "wdm-overpower-tesla-gun-beam-bounce", "wdm-overpower-tesla-gun-beam-bounce-ruby", 300, 20, 0.2, 0.05, 30),
}

local result = {}
for _, proto in ipairs(overwpower_tesla_beams) do table.insert(result, proto) end
for _, proto in ipairs(overwpower_tesla_chain) do table.insert(result, proto) end

return result