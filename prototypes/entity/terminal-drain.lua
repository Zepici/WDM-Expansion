local terminal_drain_by_level = {
    [0] = "0.15MW",
    [1] = "0.30MW",
    [2] = "0.60MW",
    [3] = "1.50MW",
    [4] = "3.00MW",
    [5] = "5.10MW",
    [6] = "7.80MW",
    [7] = "11.10MW",
    [8] = "15.00MW"
}

local function make_terminal_drain_entity(level, drain)
    return {
        type = "electric-energy-interface",
        name = "wdm-terminal-drain-" .. level,
        localised_name = {"entity-name.wdm-terminal-drain"},
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/terminal-drain.png",
        icon_size = 64,
        flags = {
            "placeable-off-grid",
            "not-on-map",
            "not-blueprintable",
            "not-deconstructable",
            "not-flammable",
            "hide-alt-info"
        },
        selectable_in_game = false,
        collision_box = {{-2, -2}, {2, 2}},
        selection_box = {{-2, -2}, {2, 2}},
        selection_priority = 40,
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            buffer_capacity = "1MJ",
            input_flow_limit = drain,
            output_flow_limit = "0W",
            drain = drain
        },
        energy_production = "0W",
        energy_usage = "0W",
        hidden = true,
        picture = {
            filename = "__core__/graphics/empty.png",
            priority = "extra-high",
            width = 1,
            height = 1
        }
    }
end

local entities = {}
for level = 0, 8 do
    table.insert(entities, make_terminal_drain_entity(level, terminal_drain_by_level[level]))
end

return entities
