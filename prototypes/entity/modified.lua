local utils = require("utils")

return {
    ["ancient-drill"] = {
        resource_categories = {"warponium-solid", "warponium-hard-solid"},
        mining_speed = 8,
        resource_drain_rate_percent = 85,
        mining_drill_radius = 1,
        resource_searching_radius = 5.5,
        radius_visualisation_picture = {
            filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-radius-visualization.png",
            width = 5.5,
            height = 5.5
        }
    }
}