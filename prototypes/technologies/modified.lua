
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
    ["artillery-shell-range-1"] = {
        effects = {
            { type = "artillery-range", modifier = 0.1 }
        },
    },
    ["wdm_warponium_processing"] = {
        prerequisites = { "engine", "wdm_warp_drive_tech-1" }
    },
    ["wdm_spaceship_solarium-3"] = {
        prerequisites = { "utility-science-pack", "wdm_spaceship_solarium-2", "warponium-solar-panel" }
    },
    ["ancient-drill"] = {
        prerequisites = { "warponium-hypercube", "wdm_warp_drive_tech-6", "production-science-pack" },
        unit = {
            count = 400,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"military-science-pack", 1},
                {"production-science-pack", 1}
            },
            time = 80
        }
    }
}

if mods["space-age"] then
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
    tech["ancient-drill"] = {
        prerequisites = { "warponium-hypercube", "wdm_warp_drive_tech-5", "space-science-pack" },
        unit = {
            count = 400,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"military-science-pack", 1},
                {"production-science-pack", 1},
                {"space-science-pack", 1}
            },
            time = 80
        }
    }
end

return tech