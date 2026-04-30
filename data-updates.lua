require("prototypes.other.other")
local utils = require("utils")

utils.modify_data(data.raw["technology"], require("prototypes.technologies.modified"))
utils.modify_data(data.raw["recipe"], require("prototypes.recipes.modified"))

local stun_sticker = data.raw["sticker"] and data.raw["sticker"]["stun-sticker"]
if stun_sticker and not data.raw["sticker"]["wdm-short-stun-sticker"] then
    local short_stun_sticker = table.deepcopy(stun_sticker)
    short_stun_sticker.name = "wdm-short-stun-sticker"
    short_stun_sticker.duration_in_ticks = 60
    data:extend({ short_stun_sticker })
end
if stun_sticker and not data.raw["sticker"]["wdm-short-2-stun-sticker"] then
    local short_stun_sticker = table.deepcopy(stun_sticker)
    short_stun_sticker.name = "wdm-short-2-stun-sticker"
    short_stun_sticker.duration_in_ticks = 120
    data:extend({ short_stun_sticker })
end

local function replace_sticker_in_trigger(trigger_effects, old_sticker, new_sticker)
    if type(trigger_effects) ~= "table" then return false end

    local replaced = false

    if trigger_effects.type == "create-sticker" and trigger_effects.sticker == old_sticker then
        trigger_effects.sticker = new_sticker
        return true
    end

    for _, effect in pairs(trigger_effects) do
        if type(effect) == "table" and replace_sticker_in_trigger(effect, old_sticker, new_sticker) then
            replaced = true
        end
    end

    return replaced
end

local function replace_push_back_distance(trigger_effects, old_distance, new_distance)
    if type(trigger_effects) ~= "table" then return false end

    local replaced = false

    if trigger_effects.type == "push-back" and trigger_effects.distance == old_distance then
        trigger_effects.distance = new_distance
        return true
    end

    for _, effect in pairs(trigger_effects) do
        if type(effect) == "table" and replace_push_back_distance(effect, old_distance, new_distance) then
            replaced = true
        end
    end

    return replaced
end

local pdd = data.raw["active-defense-equipment"] and data.raw["active-defense-equipment"]["pamk3-pdd"]
local dis = data.raw["active-defense-equipment"] and data.raw["active-defense-equipment"]["discharge-defense-equipment"]
if pdd and pdd.attack_parameters and pdd.attack_parameters.ammo_type then
    replace_sticker_in_trigger(
        pdd.attack_parameters.ammo_type.action,
        "stun-sticker",
        "wdm-short-stun-sticker"
    )
    replace_push_back_distance(
        pdd.attack_parameters.ammo_type.action,
        4,
        3
    )
end
if dis and dis.attack_parameters and dis.attack_parameters.ammo_type then
    replace_sticker_in_trigger(
        dis.attack_parameters.ammo_type.action,
        "stun-sticker",
        "wdm-short-2-stun-sticker"
    )
end

table.insert(data.raw.unit["maf-boss-biter-1"].loot, {
    item = "emergency-return",
    probability = 0.25,
    count_min = 1,
    count_max = 2
})

if mods["Cold_biters"] then
    for k = 1, 10 do
        for _, name in pairs({
            "maf-boss-frost-spitter-" .. k,
            "maf-boss-frost-biter-" .. k
        }) do
            local unit = data.raw.unit[name]
            if unit then
                unit.loot = table.deepcopy(unit.loot or {})
                table.insert(unit.loot, {
                    item = "cb_alien_cold_artifact",
                    probability = 0.25,
                    count_min = 10,
                    count_max = 50
                })
            end
        end
    end
end

if mods["teleporting_machine"] then 
--	table.insert(data.raw.recipe["emergency-return"].ingredients, {type = "item", name = "warponium-plate", amount = 10})
	table.insert(data.raw.technology["emergency-return"].prerequisites, "teleporting_machine")
end

local function scale_radius_fields(prototype, scale)
    if type(prototype) ~= "table" then return end

    if type(prototype.radius) == "number" then
        prototype.radius = prototype.radius * scale
    end

    for _, value in pairs(prototype) do
        if type(value) == "table" then
            scale_radius_fields(value, scale)
        end
    end
end

local atomic_rocket = data.raw["projectile"] and data.raw["projectile"]["atomic-rocket"]
if atomic_rocket and atomic_rocket.action then
    scale_radius_fields(atomic_rocket.action, 0.6)
end
