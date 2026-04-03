local recipes = {
    ["pamk3-se"] = {
        ingredients = {
            { type = "item", name = "steel-plate",               amount = 100 },
            { type = "item", name = "low-density-structure",     amount = 200 },
            { type = "item", name = "processing-unit",           amount = 100 },
            { type = "item", name = "fission-reactor-equipment", amount = 1 },
            { type = "item", name = "pamk3-esmk3",               amount = 5 },
            { type = "item", name = "warponium-plate",           amount = 100 }
        }
    },
    ["pamk3-pdd"] = {
        ingredients = {
            { type = "item", name = "discharge-defense-equipment", amount = 1 },
            { type = "item", name = "processing-unit",             amount = 20 },
            { type = "item", name = "warponium-plate",             amount = 20 }
        }
    },
    ["pamk3-esmk3"] = {
        ingredients = {
            { type = "item", name = "energy-shield-mk2-equipment", amount = 10 },
            { type = "item", name = "low-density-structure",       amount = 30 },
            { type = "item", name = "processing-unit",             amount = 50 },
            { type = "item", name = "warponium-plate",             amount = 20 }
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
    recipes["pamk3-se"] = {
        ingredients = {
            { type = "item", name = "tungsten-plate",            amount = 200 },
            { type = "item", name = "carbon-fiber",              amount = 100 },
            { type = "item", name = "fusion-reactor-equipment",  amount = 1 },
            { type = "item", name = "battery-mk3-equipment",     amount = 5 },
            { type = "item", name = "pamk3-esmk3",               amount = 5 },
            { type = "item", name = "warponium-plate",           amount = 100 }
        }
    }
    recipes["pamk3-esmk3"] = {
        ingredients = {
            { type = "item", name = "processing-unit",             amount = 50 },
            { type = "item", name = "tungsten-carbide",            amount = 50 },
            { type = "item", name = "energy-shield-mk2-equipment", amount = 10 },
            { type = "item", name = "warponium-plate",             amount = 20 }
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

return recipes