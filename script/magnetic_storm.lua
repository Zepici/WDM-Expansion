-- Magnetic Storm Overload Handler
-- Destroys electrical machinery built during extreme magnetic storms (>80)
-- Only active when Space Age is enabled

local function entity_built(event)
    local entity = event.entity or event.created_entity
    if not (entity and entity.valid) then return end

    local surface = entity.surface
    if not (surface and surface.valid and surface.get_property) then return end

    local ok, magnetic_storm = pcall(function()
        return surface.get_property("magnetic-storm")
    end)
    if not (ok and type(magnetic_storm) == "number") then return end

    -- Destroy electrical machines if the storm is above 80
    if magnetic_storm > 80 then
        local has_input = pcall(function()
            return entity.get_electric_input_flow_limit() ~= nil
        end)
        if has_input then
            entity.die()
            return
        end

        local has_output = pcall(function()
            return entity.get_electric_output_flow_limit() ~= nil
        end)
        if has_output then
            entity.die()
            return
        end
    end
end

local lib = {
    events = {
        [defines.events.on_built_entity] = entity_built,
        [defines.events.on_robot_built_entity] = entity_built
    }
}

return lib