local function internal_log(value)
    log(value)
end

local function log_table_internal(table, depth)
    if table == nil then return end
    for key, value in pairs(table) do
        
        local keystring
        if type(key) == "number" then
            keystring = ""
        else
            keystring = key .. " = "
        end

        local type = type(value)
        if type == "table" then
            internal_log(string.rep("\t", depth) .. keystring .. "{")
            log_table_internal(value, depth + 1)
            internal_log(string.rep("\t", depth) .. "},")
        else
            if type == "string" then
                internal_log(string.rep("\t", depth) .. keystring .. "\"" .. tostring(value) .. "\",")
            else
                internal_log(string.rep("\t", depth) .. keystring .. tostring(value) .. ",")
            end
        end
    end
end

local function log_table(table)
    log_table_internal(table, 0)
end

local function table_contains_value(table, value)
    for _, table_value in pairs(table) do
        if table_value == value then return true end
    end
    return false
end

local function table_contains_key(table, key)
    return table[key] ~= nil
end

local function remove_data(table, names)
    for _, name in pairs(names) do
        table[name] = nil
    end
end

local function disable_data(table, names)
    for _, name in pairs(names) do
        local object = table[name]
        if object then
            object.hidden = true
            object.enabled = false
        end
    end
end

local infinity_tint = { r = 1, g = 0.5, b = 1, a = 1 }

local function is_sprite(array)
    return array.icon or array.width and array.height and (array.filename or array.stripes or array.filenames)
end

local function tint(array)
    for _, value in pairs(array) do
        if type(value) == "table" then
            if is_sprite(value) then
                value.tint = infinity_tint
            end
            value = tint(value)
        end
    end
    return array
end

local function modify_data_internal(base, properties)
    for key, value in pairs(properties) do
        if type(value) == "table" then
            if value._base then
                base[key] = table.deepcopy(value._base)
                value._base = nil
            end
            if value._tint then
                value._tint = nil
                tint(base[key])
            end
            if value._replace or value[1] or not base[key] then
                base[key] = value
                base[key]._replace = nil
            else
                modify_data_internal(base[key], value)
            end
        else
            if value == -1 then
                base[key] = nil
            else
                base[key] = value
            end
        end
    end
end

local function modify_data(base, properties)
    if base == nil then return end
    for key, value in pairs(properties) do
        if base[key] then
            modify_data_internal(base[key], value)
        end
    end
end

local function add_data(objects)
    local new_data = {}
    modify_data_internal(new_data, objects)
    data:extend(new_data)
end

local function concat_array(a, b)
    local fusedArray = {}
    local n=0
    for k,v in ipairs(a) do 
        n=n+1
        fusedArray[n] = v
    end
    for k,v in ipairs(b) do 
        n=n+1
        fusedArray[n] = v
    end
    return fusedArray;
end

local function modify_size(data, scale, in_ending)
    -- Поля, которые нельзя менять внутри ending_attack_animation
    local forbidden_in_ending = {
        frame_sequence = true,
        frame_count = true,
        line_length = true,
        direction_count = true,
        run_mode = true,
        animation_speed = true,
        attack_parameters = true
    }

    local globally_forbidden = {
        frame_sequence = true,
        frame_count = true,
        attack_parameters = true
    }

    if type(data) == "table" and data[1] and type(data[1]) == "number" and data[2] and type(data[2]) == "number" then
        data[1] = tonumber(string.format("%.2f", data[1] * scale))
        data[2] = tonumber(string.format("%.2f", data[2] * scale))
        return
    end

    for key, value in pairs(data) do
        local t = type(value)

        if in_ending and forbidden_in_ending[key] then
        elseif globally_forbidden[key] then
        elseif (key == "scale" or key == "projectile_creation_distance") and t == "number" then
            data[key] = tonumber(string.format("%.2f", value * scale))
        elseif key == "range" or key == "min_range" then
            if t == "number" then
                data[key] = tonumber(string.format("%.2f", value * scale))
            end
        elseif (key == "collision_box" or key == "selection_box" or key == "drawing_box") and t == "table" then
            for i, box in ipairs(value) do
                if type(box) == "table" then
                    modify_size(box, scale, in_ending)
                end
            end
        elseif t == "table" then
            local next_in_ending = in_ending or (key == "ending_attack_animation")
            modify_size(value, scale, next_in_ending)
        end
    end
end




return {
    log_table = log_table,
    table_contains_value = table_contains_value,
    table_contains_key = table_contains_key,
    modify_data = modify_data,
    remove_data = remove_data,
    disable_data = disable_data,
    add_data = add_data,
    infinity_tint = infinity_tint,
    tint = tint,
    concat_array = concat_array,
    modify_size = modify_size
}
