local prototypes_out = {}

-- Проверяем тип урона
if not (data.raw["damage-type"] and data.raw["damage-type"]["kr-radioactive"]) then 
    prototypes_out[#prototypes_out + 1] = { type = "damage-type", name = "radiation" } 
end

local PROTOTYPE_NAME = "wdm-radioactive-ground"
local GREEN = { r = 0.41, g = 0.82, b = 0.36, a = 1 }
local GREEN_2 = { r = 0.32, g = 0.52, b = 0.30, a = 1 }
local GREEN_SECONDARY = { r = 0.25, g = 0.79, b = 0.13, a = 1 }
local HAS_SPACE_AGE = mods and mods["space-age"] ~= nil

-- Берём строго dirt-1 за основу
local source_tile = data.raw["tile"] and data.raw["tile"]["dirt-1"]

if source_tile then
    local tile = table.deepcopy(source_tile)
    tile.name = PROTOTYPE_NAME
    tile.order = "a[wdm-radioactive-ground]"
    tile.subgroup = nil
    tile.tint = GREEN
    tile.map_color = GREEN_2
    tile.effect_color = GREEN
    tile.effect_color_secondary = GREEN_SECONDARY
    tile.walking_speed_modifier = 0.6
    tile.vehicle_friction_modifier = 1.15
    tile.autoplace = nil
    tile.is_foundation = false
    tile.searchable = true

    if HAS_SPACE_AGE then
        tile.variants = tile.variants or {}
        tile.variants.main = { { picture = "__space-age__/graphics/terrain/gleba/wetland-dead-skin.png", count = 1, size = 1, scale = 0.5 } }
        if data.raw["tile-effect"] and data.raw["tile-effect"]["wetland-grey"] then 
            tile.effect = "wetland-grey" 
        end
        tile.layer = 3
        tile.layer_group = "water"
    else
        local deepwater = data.raw["tile"] and data.raw["tile"]["deepwater-green"]
        if deepwater then
            if deepwater.variants then tile.variants = table.deepcopy(deepwater.variants)
            elseif deepwater.picture then tile.picture = table.deepcopy(deepwater.picture) end
            if deepwater.sprite then tile.sprite = table.deepcopy(deepwater.sprite) end
            
            if deepwater.effect then tile.effect = deepwater.effect
            elseif data.raw["tile-effect"] and data.raw["tile-effect"]["water"] then tile.effect = "water" end
            
            tile.layer = deepwater.layer or tile.layer
            tile.layer_group = deepwater.layer_group or tile.layer_group
        end
        tile.tint = GREEN
        tile.map_color = GREEN_2
        tile.effect_color = GREEN
        tile.effect_color_secondary = GREEN_SECONDARY
    end

    prototypes_out[#prototypes_out + 1] = tile
end

return prototypes_out
