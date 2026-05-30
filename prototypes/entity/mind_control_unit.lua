local use_tesla_beams = mods["space-age"] ~= nil
local beam_blend_mode = "additive"
local beam_non_light_flags = { "trilinear-filtering" }
local space_age_sounds = use_tesla_beams and require("__space-age__.prototypes.entity.sounds") or nil


function make_tesla_electric_beam_graphics(blend_mode, beam_flags, beam_tint, base_graphics_set, scale)
  scale = scale or 1
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
      scale = 1 * scale
    }),
    ending = util.sprite_load("__space-age__/graphics/entity/beam/tesla-beam-END",
    {
      flags = beam_flags or beam_non_light_flags,
      frame_count = 20,
      draw_as_glow = true,
      tint = beam_tint,
      animation_speed = 0.5,
      scale = 1 * scale
    }),
    head = util.sprite_load("__space-age__/graphics/entity/beam/tesla-head",
    {
      flags = beam_flags or beam_non_light_flags,
      frame_count = 20,
      draw_as_glow = true,
      animation_speed = 0.5,
      scale = 1 * scale,
      tint = beam_tint,
      blend_mode = blend_mode or beam_blend_mode
    }),
    tail = util.sprite_load("__space-age__/graphics/entity/beam/tesla-tail",
    {
      flags = beam_flags or beam_non_light_flags,
      frame_count = 20,
      draw_as_glow = true,
      animation_speed = 0.5,
      scale = 1 * scale,
      tint = beam_tint,
      blend_mode = blend_mode or beam_blend_mode
    }),
    body =
    {
      {layers=get_beam_sprite('1')},
      {layers=get_beam_sprite('2')},
      {layers=get_beam_sprite('3')},
      {layers=get_beam_sprite('4')},
      {layers=get_beam_sprite('5')},
      {layers=get_beam_sprite('6')},
    }
  }
  return graphics_set
end

function make_tesla_beam(name, sound, damage, scale)
  scale = scale or 1
  return
  {
    name = name, 
    type = "beam",
    flags = {"not-on-map"},
    hidden = true,
    width = 0.5,
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
            damage = { amount = damage, type = "electric"}
          },
          {
            type = "create-sticker",
            sticker = "tesla-turret-slow"
          },
          {
            type = "play-sound",
            sound = space_age_sounds.tesla_turret_beam_deflect
          },
          {
            type = "play-sound",
            sound = "__Warp-Drive-Machine-Expansion__/sounds/beam-sound.ogg"
          }          
        }
      }
    },
    graphics_set = make_tesla_electric_beam_graphics(beam_blend_mode, beam_non_light_flags, nil,
                                                     {
                                                       desired_segment_length = 1,
                                                       randomize_animation_per_segment = true
                                                     }, scale),
    working_sound =
    sound and {
      sound = {category = "weapon", filename = "__space-age__/sound/entity/tesla-turret/tesla-turret-beam.ogg", volume = 1.0},
      max_sounds_per_type = 4
    } or nil,
  }
end


if use_tesla_beams then
  data:extend({
    make_tesla_beam("mf_single_electric_beam", true, 0),
    make_tesla_beam("mf_single_electric_beam_small", true, 0, 0.5)
  })
end




-- Контролирующий враг - наносит урон с эффектом контроля ума
local path = "__Warp-Drive-Machine-Expansion__"
local robot_scale = 3
--local robot_tint = {r=0.8, g=0.2, b=0.8, a=1}

local animation_layers = {
  {
    filename = path .. "/graphics/entity/flying-robot/flying_robot_base.png",
    priority = "high",
    line_length = 4,
    width = 4000 / 4,
    height = 4000 / 4,
    animation_speed = 1,
    direction_count = 16,
    shift = {0, -0.5},
    scale = 0.125 * robot_scale
  },
  {
    filename = path .. "/graphics/entity/flying-robot/flying_robot_shadow.png",
    priority = "high",
    line_length = 4,
    width = 2000 / 4,
    height = 2000 / 4,
    animation_speed = 1,
    direction_count = 16,
    shift = {2.5, 0.5},
    scale = 0.25 * robot_scale,
    draw_as_shadow = true
  },
  {
    filename = path .. "/graphics/entity/flying-robot/eye.png",
    priority = "high",
    line_length = 4,
    width = 2000 / 4,
    height = 2000 / 4,
    animation_speed = 1,
    direction_count = 16,
    shift = {0, -0.5},
    scale = 0.25 * robot_scale,
    draw_as_glow = true,
    blend_mode = "additive"
  },
  {
    filename = path .. "/graphics/entity/flying-robot/fire.png",
    priority = "high",
    line_length = 4,
    width = 2000 / 4,
    height = 2000 / 4,
    animation_speed = 1,
    direction_count = 16,
    shift = {0, -0.5},
    scale = 0.25 * robot_scale,
    draw_as_glow = true,
    blend_mode = "additive"
  }
}

-- Инжектим маску окрашивания, если задан robot_tint
--[[
if robot_tint then
  table.insert(animation_layers, {
    filename = path .. "/graphics/flying_robot_mask.png",
    priority = "high",
    line_length = 4,
    width = 2000 / 4,
    height = 2000 / 4,
    animation_speed = 1,
    direction_count = 16,
    shift = {0, -0.5},
    scale = 0.25 * robot_scale,
    tint = robot_tint
  })
end
]]
local final_robot_animation = {
  layers = animation_layers
}


-- makes remnants work with more than 1 variation
local function FE_make_rotated_animation_variations_from_sheet(variation_count, sheet)
  local result = {}
  local function set_offset(variation, x, y)
    local frame_count = variation.frame_count or 1
    local line_length = variation.line_length or frame_count
    if (line_length < 1) then
      line_length = frame_count
    end
    local height_in_frames = math.floor((frame_count * variation.direction_count + line_length - 1) / line_length)
    local width_in_frames = math.floor((frame_count * variation.direction_count + line_length - 1) / line_length)
    variation.y = variation.height * (y - 1) * height_in_frames
    variation.x = variation.width * (x - 1) * width_in_frames
  end
  for y = 1,variation_count do
    for x = 1,variation_count do
      local variation = util.table.deepcopy(sheet)
      if variation.layers then
        for _, layer in pairs(variation.layers) do
          set_offset(layer, x, y)
        end
      else
        set_offset(variation, x, y)
      end
      table.insert(result, variation)
    end
  end
  return result
end


function make_robot_corpse(scale, tint)
  return FE_make_rotated_animation_variations_from_sheet(4,{
    layers=
    {
      {
        filename = path .. "/graphics/entity/flying-robot/dead.png",
        line_length = 4,
        width = 2000/4,
        height = 2000/4,
        direction_count = 1,
        scale = 0.25 * scale
      },
      {
        filename = path .. "/graphics/entity/flying-robot/dead_mask.png",
        line_length = 4,
        width = 2000/4,
        height = 2000/4,
        direction_count = 1,
        tint = tint,
        scale = 0.25 * scale
      },     
      {
        filename = path .. "/graphics/entity/flying-robot/dead_shadow.png",
        line_length = 4,
        width = 2000/4,
        height = 2000/4,
        direction_count = 1,
        tint = tint,
        scale = 0.25 * scale,
        draw_as_shadow = true
      }
    }
  })
end

local main_beam = use_tesla_beams and "mf_single_electric_beam" or "electric-beam"
local reaction_beam = use_tesla_beams and "mf_single_electric_beam_small" or "electric-beam"

local function scale_animation_layers(layers, scale_factor)
  local scaled_layers = {}
  for _, layer in ipairs(layers) do
    local new_layer = {}
    for k, v in pairs(layer) do
      new_layer[k] = v
    end
    new_layer.scale = (layer.scale or 1) * scale_factor
    table.insert(scaled_layers, new_layer)
  end
  return scaled_layers
end

local function scale_box(box, factor)
  return {
    {box[1][1] * factor, box[1][2] * factor}, 
    {box[2][1] * factor, box[2][2] * factor}
  }
end

local function create_mcu_tier(tier)
local final_hp = 20000 * tier

-- Линейные множители без степеней
local multiplier = tier
local damage_multiplier = 1 + 0.1 * (tier - 1)
local scale_factor = 1 + 0.05 * (tier - 1) 
local resistance_multiplier = 1 + 0.15 * (tier - 1)

local scaled_animation = {
  layers = scale_animation_layers(animation_layers, scale_factor)
}


return {
    type = "unit",
    name = "mind-control-unit-" .. tier,
    localised_name = {"entity-name.mind-control-unit"},
    localised_description = {"entity-description.mind-control-unit"},
    icons = {{icon = path .. "/graphics/icon/flying_robot_base_icon.png", tint = robot_tint, icon_size = 64}},
    max_health = final_hp,
    subgroup = "enemies",
    order = "b[mind-control-unit]-" .. tier,
    dying_explosion = "blood-explosion-huge",
    corpse = "mind-control-unit-corpse-" .. tier,
    collision_box = scale_box({{-3.6, -3.2}, {3.6, 2.0}}, scale_factor),
    selection_box = scale_box({{-3.6, -3.2}, {3.6, 2.0}}, scale_factor),
    sticker_box = scale_box({{-0.9, -0.8}, {0.9, 0.45}}, scale_factor),
    run_animation = scaled_animation,
    movement_speed = 0.1,
    distance_per_frame = 0.2,
    distraction_cooldown = 120,
    vision_distance = 60, 
    flags = {"placeable-enemy", "placeable-off-grid", "breaths-air", "not-repairable"},
    light = {
      intensity = 0.5 + (tier * 0.03), -- Простая линейная прибавка к яркости света
      size = 12 * scale_factor,
      color = {r = 0.0, g = 0.4, b = 0.95},
      shift = {0, -0.6 * scale_factor} 
    },
    healing_per_tick = 0.44,
    hide_resistances = false,
    resistances = {
      {
        type = "acid",
        percent = 12 * resistance_multiplier
      },
      {
        type = "electric",
        percent = -12 * resistance_multiplier
      },
      {
        type = "explosion",
        percent = 12 * resistance_multiplier
      },
      {
        type = "fire",
        percent = 12 * resistance_multiplier
      },
      {
        type = "impact",
        percent = 12 * resistance_multiplier
      },
      {
        type = "laser",
        percent = 12 * resistance_multiplier
      },
      {
        type = "physical",
        percent = 12 * resistance_multiplier
      },
      {
        type = "poison",
        percent = -12 * resistance_multiplier
      }
    },
    attack_parameters = {
      type = "beam",
      ammo_category = "biological",
      cooldown = 900,
      range = 40,
      damage_modifier = 1.5 * damage_multiplier,
      warmup = 0,
      animation = scaled_animation,
      ammo_type = {
        category = "beam",
        target_type = "entity",
        action = {
          type = "direct",
          action_delivery = {
            type = "beam",
            beam = main_beam, 
            duration = 20,
            target_effects = {
              {
                type = "script",
                effect_id = "wdm-mind-control-effect"
              },
--              {
--                type = "create-explosion",
--                entity_name = "dark-explosion"
--              },
              {
                type = "nested-result",
                action = {
                  type = "area",
                  radius = 2,
                  action_delivery = {
                    type = "instant",
                    target_effects = {
                      {
                        type = "damage",
                        damage = {amount = 88 * damage_multiplier, type = "electric"}
                      },
                      {
                        type = "create-explosion",
                        entity_name = "dark-explosion"
                      }
                    }
                  }
                }
              }             
            }
          }
        }
      }
    },
    attack_reaction = {
    {
      damage_type = "physical",
      range = 10,
      action = {
        type = "direct",
        action_delivery = {
          type = "beam",
          beam = reaction_beam, 
          duration = 20,
          target_effects = {
            {
              type = "script",
              effect_id = "wdm-mind-control-effect"
            },
            {
              type = "create-explosion",
              entity_name = "dark-explosion"
            },
            {
              type = "damage",
              damage = {amount = 44 * damage_multiplier, type = "electric"}
            }
          }
        }
      }
    },
    {
      damage_type = "explosion",
      range = 10,
      action = {
        type = "direct",
        action_delivery = {
          type = "beam",
          beam = reaction_beam, 
          duration = 20,
          target_effects = {
            {
              type = "script",
              effect_id = "wdm-mind-control-effect"
            },
            {
              type = "create-explosion",
              entity_name = "dark-explosion"
            },
            {
              type = "damage",
              damage = {amount = 44 * damage_multiplier, type = "electric"}
            }
          }
        }
      }
    },
    {
      damage_type = "laser",
      range = 10,
      action = {
        type = "direct",
        action_delivery = {
          type = "beam",
          beam = reaction_beam, 
          duration = 20,
          target_effects = {
            {
              type = "script",
              effect_id = "wdm-mind-control-effect"
            },
            {
              type = "create-explosion",
              entity_name = "dark-explosion"
            },
            {
              type = "damage",
              damage = {amount = 44 * damage_multiplier, type = "electric"}
            }
          }
        }
      }
    },
    {
      damage_type = "impact",
      range = 10,
      action = {
        type = "direct",
        action_delivery = {
          type = "beam",
          beam = reaction_beam, 
          duration = 20,
          target_effects = {
            {
              type = "script",
              effect_id = "wdm-mind-control-effect"
            },
            {
              type = "create-explosion",
              entity_name = "dark-explosion"
            },
            {
              type = "damage",
              damage = {amount = 11 * damage_multiplier, type = "electric"}
            }
          }
        }
      }
    }
  },
    
    allow_run_time_change_of_is_military_target = false,
    is_military_target = true
  }
end


local mcu_tiers = {}
for tier = 1, 10 do
  table.insert(mcu_tiers, create_mcu_tier(tier))
end

-- Создаем прототипы останков (corpse) для каждого уровня MCU
for tier = 1, 10 do
  local multiplier = math.pow(1.2915, tier - 1)
  local scale_factor = math.pow(multiplier, 0.15)
  table.insert(mcu_tiers, {
    type = "corpse",
    name = "mind-control-unit-corpse-" .. tier,
    icon = "__base__/graphics/icons/defender.png",
    tile_width = 3,
    tile_height = 3,
    selectable_in_game = false,
    subgroup = "remnants",
    order = "d[remnants]-a[generic]-a[small]",
    time_before_removed = 60 * 60 * 15,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = make_robot_corpse(scale_factor * robot_scale, robot_tint)
  })
end

return mcu_tiers
