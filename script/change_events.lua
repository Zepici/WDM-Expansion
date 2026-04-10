local change_events = {}

local DEFAULT_EVENT_OVERRIDES = {
    pirates = {
        chance = 0.17,
        difficulty_add = 0.01
    }
}

local function apply_override(event_name, property_name, value)
    if not (remote and remote.interfaces and remote.interfaces["WDM"]) then
        return false
    end

    local ok = pcall(function()
        remote.call("WDM", "change_default_planet_event", event_name, property_name, value)
    end)

    return ok
end

function change_events.apply_default_event_overrides()
    for event_name, properties in pairs(DEFAULT_EVENT_OVERRIDES) do
        for property_name, value in pairs(properties) do
            apply_override(event_name, property_name, value)
        end
    end
end

return change_events
