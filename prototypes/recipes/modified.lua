local recipes = {
    ["warponium-fluid"] = {
        ingredients = {
            { type = "fluid", name = "steam",                      amount = 500 },
            { type = "fluid", name = "heavy-oil",                  amount = 40 },
            { type = "item",  name = "warponium-plate",            amount = 10 }
        }
    },
    ["wdm_pirate_ship_search_probe"] = {
        ingredients = {
            { type = "item", name = "warponium-plate", amount = 500 },
            { type = "item", name = "warponium-hypercube", amount = 50 },
            { type = "item", name = "processing-unit",       amount = 300 },
            { type = "item", name = "satellite",       amount = 20 },
            { type = "item", name = "radar",       amount = 100 }
        }   
    },
    ["ancient-drill"] = {
            ingredients = {
                { type = "item", name = "warponium-hypercube",         amount = 50 },
                { type = "item", name = "processing-unit",             amount = 50 },
                { type = "item", name = "steel-plate",                 amount = 250 },
                { type = "item", name = "iron-stick",                  amount = 100 },
                { type = "fluid", name = "lubricant",                   amount = 300 },
                { type = "item", name = "electric-engine-unit",        amount = 25 }
            }
        }
}

if mods["space-age"] then
    recipes["fusion-reactor-equipment"] = {
        ingredients = {
            { type = "item", name = "tungsten-plate",            amount = 250 },
            { type = "item", name = "supercapacitor",            amount = 25 },
            { type = "item", name = "carbon-fiber",              amount = 100 },
            { type = "item", name = "quantum-processor",         amount = 50 },
            { type = "item", name = "fusion-power-cell",         amount = 5 },
            { type = "item", name = "fission-reactor-equipment", amount = 1 }         
        }
    }
    recipes["ancient-drill"] = {
        surface_conditions = -1,
        ingredients = {
            { type = "item", name = "warponium-hypercube",         amount = 25 },
            { type = "item", name = "processing-unit",             amount = 50 },
            { type = "item", name = "steel-plate",                 amount = 150 },
            { type = "item", name = "iron-stick",                  amount = 100 },
            { type = "fluid", name = "lubricant",                  amount = 200 },
            { type = "item", name = "electric-engine-unit",        amount = 25 }
        }
    }   
end

if mods["Cold_biters"] and not mods["Explosive_biters"] then
    recipes["cb-modular-armor"] = {
        ingredients = {
            { type = "item", name = "cb_alien_cold_artifact", amount = 5 },
            { type = "item", name = "modular-armor",       amount = 1 }
        }   
    }
    recipes["cb-power-armor"] = {
        ingredients = {
            { type = "item", name = "cb_alien_cold_artifact", amount = 10 },
            { type = "item", name = "power-armor",       amount = 1 }
        }   
    }
    recipes["cb-power-armor-mk2"] = {
        ingredients = {
            { type = "item", name = "cb_alien_cold_artifact", amount = 15 },
            { type = "item", name = "power-armor-mk2",       amount = 1 }
        }   
    }
end
if settings.startup["wdm-expansion-event-enable"].value then
    recipes["wdm_pirate_ship_search_probe"] = {
        ingredients = {
            { type = "item", name = "warponium-plate", amount = 500 },
            { type = "item", name = "warponium-hypercube", amount = 50 },
            { type = "item", name = "processing-unit",       amount = 300 },
            { type = "item", name = "satellite",       amount = 20 },
            { type = "item", name = "radar",       amount = 100 },
            { type = "item", name = "charged-crystal",       amount = 1 }                   
        }   
    }
end
return recipes