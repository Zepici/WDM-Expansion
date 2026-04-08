local BUFFED_PREFIX = "wdm-red-concrete-buffed-"
local DAMAGE_MULTIPLIER = 1.05
local FIRE_RATE_MULTIPLIER = 1.05

local variants = {}

local function add_buffed_variants_for_type(turret_type)
    for name, turret in pairs(data.raw[turret_type] or {}) do
        if string.sub(name, 1, #BUFFED_PREFIX) ~= BUFFED_PREFIX then
            local copy = table.deepcopy(turret)
            copy.name = BUFFED_PREFIX .. name
            copy.hidden = true
            copy.hidden_in_factoriopedia = true
            copy.localised_name = turret.localised_name or {"entity-name." .. name}
            if turret.localised_description then
                copy.localised_description = {
                    "",
                    turret.localised_description,
                    "\n",
                    {"wdm-expansion.turret_red_concrete_variant_desc"}
                }
            else
                copy.localised_description = {"wdm-expansion.turret_red_concrete_variant_desc"}
            end

            -- Keep mining result as the original turret item.
            if copy.minable and not copy.minable.result and not copy.minable.results then
                copy.minable.result = name
            end

            local ap = copy.attack_parameters
            if ap then
                if type(ap.cooldown) == "number" and ap.cooldown > 0 then
                    ap.cooldown = math.max(1, math.floor((ap.cooldown / FIRE_RATE_MULTIPLIER) + 0.5))
                end

                if type(ap.minimum_attack_cycle_duration) == "number" and ap.minimum_attack_cycle_duration > 0 then
                    ap.minimum_attack_cycle_duration =
                        math.max(1, math.floor((ap.minimum_attack_cycle_duration / FIRE_RATE_MULTIPLIER) + 0.5))
                end

                if type(ap.damage_modifier) == "number" then
                    ap.damage_modifier = ap.damage_modifier * DAMAGE_MULTIPLIER
                else
                    ap.damage_modifier = DAMAGE_MULTIPLIER
                end
            end

            variants[#variants + 1] = copy
        end
    end
end

add_buffed_variants_for_type("ammo-turret")
add_buffed_variants_for_type("electric-turret")

if #variants > 0 then
    data:extend(variants)
end
