local turret_buff = {}

local RED_REFINED_CONCRETE_TILE = "red-refined-concrete"
local RED_CONCRETE_DAMAGE_BONUS = 0.05
local RED_CONCRETE_FIRE_RATE_BONUS = 0.05
local BUFFED_PREFIX = "wdm-red-concrete-buffed-"
local RED_CONCRETE_BONUS_LABEL_TEXT = {
    "wdm-expansion.turret_red_concrete_bonus_short",
    math.floor(RED_CONCRETE_DAMAGE_BONUS * 100),
    math.floor(RED_CONCRETE_FIRE_RATE_BONUS * 100)
}
local SUPPORTED_TURRET_TYPES = {
    ["ammo-turret"] = true,
    ["electric-turret"] = true
}

local function init_storage()
    storage.red_concrete_bonus_labels = storage.red_concrete_bonus_labels or {} -- [unit_number] = rendering_id
end

local function is_turret_bonus_text_enabled()
    if not (settings and settings.global) then return true end
    local setting = settings.global["wdm-expansion-show-turret-buff-text"]
    if setting == nil then return true end
    return setting.value and true or false
end

local function is_turret_on_red_refined_concrete(turret)
    if not (turret and turret.valid and turret.surface and turret.surface.valid and turret.bounding_box) then
        return false
    end

    local bounds = turret.bounding_box
    local min_x = math.floor(bounds.left_top.x)
    local max_x = math.ceil(bounds.right_bottom.x) - 1
    local min_y = math.floor(bounds.left_top.y)
    local max_y = math.ceil(bounds.right_bottom.y) - 1

    for x = min_x, max_x do
        for y = min_y, max_y do
            local tile = turret.surface.get_tile(x, y)
            if not (tile and tile.valid and tile.name == RED_REFINED_CONCRETE_TILE) then
                return false
            end
        end
    end

    return true
end

local function get_base_name(entity_name)
    if string.sub(entity_name, 1, #BUFFED_PREFIX) == BUFFED_PREFIX then
        return string.sub(entity_name, #BUFFED_PREFIX + 1)
    end
    return entity_name
end

local function get_buffed_name(base_name)
    return BUFFED_PREFIX .. base_name
end

local function has_entity_prototype(name)
    if not name then return false end

    if prototypes and prototypes.entity and prototypes.entity[name] then
        return true
    end

    if prototypes and prototypes.get_entity_filtered then
        local ok, found = pcall(function()
            return prototypes.get_entity_filtered({
                { filter = "name", name = name }
            })
        end)
        if ok and found then
            for _ in pairs(found) do
                return true
            end
        end
    end

    return false
end

local function remove_red_concrete_bonus_label(unit_number)
    local labels = storage.red_concrete_bonus_labels
    if not (labels and unit_number) then return end

    local id = labels[unit_number]
    if id then
        pcall(function() rendering.destroy(id) end)
    end
    labels[unit_number] = nil
end

local function is_bonus_label_text(text)
    if type(text) == "table" then
        return text[1] == "wdm-expansion.turret_red_concrete_bonus_short"
    end
    return false
end

local function destroy_all_bonus_renderings()
    local mod_name = (script and script.mod_name) or nil
    local ok_objects, objects = pcall(function()
        return rendering.get_all_objects(mod_name)
    end)
    if not ok_objects or not objects then return end

    for _, object in pairs(objects) do
        if object and object.valid and object.type == "text" then
            local ok_text, text = pcall(function() return object.text end)
            if ok_text and is_bonus_label_text(text) then
                pcall(function() object.destroy() end)
            end
        end
    end
end

local function set_red_concrete_bonus_label(turret, enabled)
    if not (turret and turret.valid and turret.unit_number) then return end
    storage.red_concrete_bonus_labels = storage.red_concrete_bonus_labels or {}
    local labels = storage.red_concrete_bonus_labels
    local id = labels[turret.unit_number]

    if not is_turret_bonus_text_enabled() then
        if id then
            remove_red_concrete_bonus_label(turret.unit_number)
        end
        return
    end

    if enabled then
        if id then return end
        labels[turret.unit_number] = rendering.draw_text{
            text = RED_CONCRETE_BONUS_LABEL_TEXT,
            surface = turret.surface,
            target = turret,
            target_offset = {0, -1.65},
            color = {r = 1.0, g = 0.2, b = 0.2, a = 0.95},
            font = "heading-1",
            alignment = "center",
            scale = 0.3,
            scale_with_zoom = false,
            only_in_alt_mode = true
        }
        return
    end

    remove_red_concrete_bonus_label(turret.unit_number)
end

local function swap_turret_entity(turret, target_name)
    if not (turret and turret.valid and target_name) then return turret end
    if turret.name == target_name then return turret end

    local old_unit_number = turret.unit_number
    if old_unit_number then
        remove_red_concrete_bonus_label(old_unit_number)
    end

    local created = turret.surface.create_entity{
        name = target_name,
        position = turret.position,
        force = turret.force,
        direction = turret.direction,
        fast_replace = true,
        spill = false,
        create_build_effect_smoke = false,
        raise_built = false
    }

    if created and created.valid then
        return created
    end

    local ammo_contents = nil
    local old_health = turret.health
    local old_direction = turret.direction
    local old_force = turret.force
    local old_surface = turret.surface
    local old_position = turret.position

    local old_ammo_inventory = turret.get_inventory(defines.inventory.turret_ammo)
    if old_ammo_inventory and old_ammo_inventory.valid then
        ammo_contents = old_ammo_inventory.get_contents()
    end

    turret.destroy({raise_destroy = false})

    created = old_surface.create_entity{
        name = target_name,
        position = old_position,
        force = old_force,
        direction = old_direction,
        spill = false,
        create_build_effect_smoke = false,
        raise_built = false
    }

    if created and created.valid then
        if old_health and created.health then
            created.health = math.min(old_health, created.prototype.max_health or old_health)
        end

        if ammo_contents then
            local new_ammo_inventory = created.get_inventory(defines.inventory.turret_ammo)
            if new_ammo_inventory and new_ammo_inventory.valid then
                for item_name, count in pairs(ammo_contents) do
                    new_ammo_inventory.insert({name = item_name, count = count})
                end
            end
        end
    end

    if created and created.valid then
        return created
    end

    return turret
end

local function ensure_turret_variant(turret)
    if not (turret and turret.valid and SUPPORTED_TURRET_TYPES[turret.type]) then return turret end

    local base_name = get_base_name(turret.name)
    local buffed_name = get_buffed_name(base_name)

    if not has_entity_prototype(buffed_name) then
        return turret
    end

    local should_buff = is_turret_on_red_refined_concrete(turret)
    local target_name = should_buff and buffed_name or base_name

    if turret.name ~= target_name then
        turret = swap_turret_entity(turret, target_name)
    end

    return turret
end

local function update_turret_red_concrete_bonus_visual(turret, show_popup)
    if not (turret and turret.valid and SUPPORTED_TURRET_TYPES[turret.type]) then return end

    local enabled = is_turret_on_red_refined_concrete(turret)
    set_red_concrete_bonus_label(turret, enabled)

    if enabled and show_popup and is_turret_bonus_text_enabled() then
        turret.surface.create_entity{
            name = "flying-text",
            position = turret.position,
            text = RED_CONCRETE_BONUS_LABEL_TEXT,
            color = {r = 1.0, g = 0.25, b = 0.25}
        }
    end
end

local function get_tile_event_area(event)
    local tiles = event and event.tiles
    if not (tiles and #tiles > 0) then return nil end

    local min_x, max_x = nil, nil
    local min_y, max_y = nil, nil

    for _, tile in ipairs(tiles) do
        local p = tile and tile.position
        if p then
            if not min_x or p.x < min_x then min_x = p.x end
            if not max_x or p.x > max_x then max_x = p.x end
            if not min_y or p.y < min_y then min_y = p.y end
            if not max_y or p.y > max_y then max_y = p.y end
        end
    end

    if not min_x then return nil end
    return {
        {min_x - 2, min_y - 2},
        {max_x + 3, max_y + 3}
    }
end

local function for_each_supported_turret(surface, area, fn)
    if not (surface and surface.valid and fn) then return end

    local ammo_turrets = surface.find_entities_filtered{type = "ammo-turret", area = area}
    for _, turret in ipairs(ammo_turrets) do
        fn(turret)
    end

    local electric_turrets = surface.find_entities_filtered{type = "electric-turret", area = area}
    for _, turret in ipairs(electric_turrets) do
        fn(turret)
    end
end

local function update_turret_bonus_visuals_in_area(surface, area)
    if not (surface and surface.valid and area) then return end
    for_each_supported_turret(surface, area, function(turret)
        local resolved = ensure_turret_variant(turret)
        update_turret_red_concrete_bonus_visual(resolved, false)
    end)
end

local function refresh_all_turret_bonus_visuals()
    -- Cleanup all known/unknown bonus labels first.
    destroy_all_bonus_renderings()

    storage.red_concrete_bonus_labels = storage.red_concrete_bonus_labels or {}
    for unit_number, id in pairs(storage.red_concrete_bonus_labels) do
        if id then
            pcall(function() rendering.destroy(id) end)
        end
        storage.red_concrete_bonus_labels[unit_number] = nil
    end

    for _, surface in pairs(game.surfaces) do
        if surface and surface.valid then
            for_each_supported_turret(surface, nil, function(turret)
                local resolved = ensure_turret_variant(turret)
                update_turret_red_concrete_bonus_visual(resolved, false)
            end)
        end
    end
end

function turret_buff.on_init_or_configuration_changed()
    init_storage()
    refresh_all_turret_bonus_visuals()
end

function turret_buff.on_entity_built(event)
    local entity = event.entity or event.created_entity
    local resolved = ensure_turret_variant(entity)
    update_turret_red_concrete_bonus_visual(resolved, true)
end

function turret_buff.on_entity_removed(event)
    local entity = event.entity
    if entity and entity.unit_number then
        remove_red_concrete_bonus_label(entity.unit_number)
    end
end

function turret_buff.on_tiles_changed(event)
    local surface = event and event.surface_index and game.surfaces[event.surface_index]
    local area = get_tile_event_area(event)
    if not area then return end
    update_turret_bonus_visuals_in_area(surface, area)
end

function turret_buff.on_runtime_mod_setting_changed(event)
    if not event then return end
    if event.setting ~= "wdm-expansion-show-turret-buff-text" then return end
    refresh_all_turret_bonus_visuals()
end

return turret_buff
