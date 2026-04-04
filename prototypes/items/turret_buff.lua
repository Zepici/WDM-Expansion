local BUFFED_PREFIX = "wdm-red-concrete-buffed-"
local ITEM_TYPES = {
    "item",
    "item-with-entity-data"
}

local variants = {}

local function find_item_for_entity(entity_name)
    for _, item_type in ipairs(ITEM_TYPES) do
        for _, item in pairs(data.raw[item_type] or {}) do
            if item.place_result == entity_name then
                return item
            end
        end
    end
    return nil
end

local function add_item_variants_for_type(turret_type)
    for name, turret in pairs(data.raw[turret_type] or {}) do
        if string.sub(name, 1, #BUFFED_PREFIX) ~= BUFFED_PREFIX then
            local source_item = find_item_for_entity(name)
            if source_item then
                local copy = table.deepcopy(source_item)
                copy.name = BUFFED_PREFIX .. source_item.name
                copy.place_result = BUFFED_PREFIX .. name
                copy.localised_name = source_item.localised_name or {"item-name." .. source_item.name}

                if source_item.localised_description then
                    copy.localised_description = {
                        "",
                        source_item.localised_description,
                        "\n",
                        {"wdm-expansion.turret_red_concrete_variant_desc"}
                    }
                else
                    copy.localised_description = {"wdm-expansion.turret_red_concrete_variant_desc"}
                end

                variants[#variants + 1] = copy
            end
        end
    end
end

add_item_variants_for_type("ammo-turret")
add_item_variants_for_type("electric-turret")

return variants
