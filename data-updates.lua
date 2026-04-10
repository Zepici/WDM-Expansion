require("prototypes.other.other")
local utils = require("utils")

utils.modify_data(data.raw["technology"], require("prototypes.technologies.modified"))
utils.modify_data(data.raw["recipe"], require("prototypes.recipes.modified"))

table.insert(data.raw.unit["maf-boss-biter-1"].loot, {
    item = "emergency-return",
    probability = 0.25,
    count_min = 1,
    count_max = 2
})

if mods["Cold_biters"] then
    for k = 1, 10 do
        for _, name in pairs({
            "maf-boss-frost-spitter-" .. k,
            "maf-boss-frost-biter-" .. k
        }) do
            local unit = data.raw.unit[name]
            if unit then
                unit.loot = table.deepcopy(unit.loot or {})
                table.insert(unit.loot, {
                    item = "cb_alien_cold_artifact",
                    probability = 0.25,
                    count_min = 10,
                    count_max = 50
                })
            end
        end
    end
end

if mods["teleporting_machine"] then 
--	table.insert(data.raw.recipe["emergency-return"].ingredients, {type = "item", name = "warponium-plate", amount = 10})
	table.insert(data.raw.technology["emergency-return"].prerequisites, "teleporting_machine")
end
