local change_events = {}

local function get_pirates_chance()
    local setting = settings.startup["wdm-expansion-pirate-event-boost"]

    if setting and setting.value then
        return 0.4
    end

    return 0.17
end

local function get_pirates_must_have()
    local setting = settings.startup["wdm-expansion-pirate-event-boost"]

    if setting and setting.value then
        return 4
    end

    return 18
end

local function get_default_event_overrides()
    return {
        pirates = {
            chance = get_pirates_chance(),
            difficulty_add = 0.01,
            must_have_on = get_pirates_must_have()
        }
    }
end

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
    local default_event_overrides = get_default_event_overrides()

    for event_name, properties in pairs(default_event_overrides) do
        for property_name, value in pairs(properties) do
            apply_override(event_name, property_name, value)
        end
    end
end

return change_events
