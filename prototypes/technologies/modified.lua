
local tech = {
    ["kj_laser"] = {
        prerequisites = { "utility-science-pack", "laser", "wdm_warponium_fuel" },
        effects = {
            { type = "unlock-recipe", recipe = "kj_electric_laser_player" },
        },
        unit = {
            count = 500,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
                { "chemical-science-pack",   1 },
                { "military-science-pack",   1 },
                { "utility-science-pack", 1 }
            },
            time = 60
        }
    },
    ["pamk3-se"] = {
        prerequisites = { "pamk3-esmk3", "fission-reactor-equipment" },
        unit = {
            count = 1000,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"military-science-pack", 1},
                {"utility-science-pack", 1},
                {"space-science-pack", 1}
            },
            time = 120
        }
    },
    ["pamk3-nvmk2"] = {
        prerequisites = { "night-vision-equipment", "utility-science-pack" }
    },
    ["artillery-shell-range-1"] = {
        effects = {
            { type = "artillery-range", modifier = 0.1 }
        },
    }
}

if mods["space-age"] then
    tech["pamk3-esmk3"] = {
        prerequisites = { "energy-shield-mk2-equipment", "power-armor-mk2", "metallurgic-science-pack" },
        unit = {
            count = 750,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "military-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "electromagnetic-science-pack", 1 }
            },
            time = 45
        }
    }
    tech["pamk3-se"] = {
        prerequisites = { "pamk3-esmk3", "fusion-reactor-equipment", "battery-mk3-equipment" },
        unit = {
            count = 1000,
            ingredients = {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "military-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "space-science-pack",           1 },
                { "metallurgic-science-pack",     1 },
                { "agricultural-science-pack",    1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack",       1 }
            },
            time = 120
        }
    }
    tech["kj_laser"] = {
        prerequisites = { "utility-science-pack", "laser", "wdm_warponium_fuel", "production-science-pack" },
        effects = {
            { type = "unlock-recipe", recipe = "kj_electric_laser_player" },
        },
        unit = {
            count = 1000,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
                { "chemical-science-pack",   1 },
                { "military-science-pack",   1 },
                { "utility-science-pack", 1 },
                { "production-science-pack", 1 }
            },
            time = 60
        }
    }
end

return tech