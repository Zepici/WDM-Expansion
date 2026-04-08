local mod_commands = {}

function mod_commands.register(opts)
    local planetary_events = opts and opts.planetary_events
    local register_wdm_blueprint_overrides = opts and opts.register_wdm_blueprint_overrides

    commands.add_command("wdm-refresh-pirate-blueprints", "Re-apply WDM pirate ship blueprint overrides.", function(command)
        local player = command.player_index and game and game.get_player(command.player_index) or nil
        local debug_fn = function(message)
            if player and player.valid then
                player.print(message)
            else
                log(message)
            end
        end

        local ok, applied = pcall(function()
            return register_wdm_blueprint_overrides(debug_fn)
        end)

        if not ok then
            local message = "Failed to refresh WDM pirate ship blueprint overrides."
            if player and player.valid then
                player.print(message)
            else
                log(message)
            end
            log("[WDM Expansion] " .. tostring(applied))
            return
        end

        local message = applied
            and "WDM pirate ship blueprint overrides refreshed."
            or "WDM pirate ship blueprint overrides were not refreshed."

        if player and player.valid then
            player.print(message)
            return
        end

        log(message)
    end)

    commands.add_command("wdm-reset-crystal-bonuses", "Reset enemy bonuses gained from mined crystals.", function(command)
        local player = command.player_index and game and game.get_player(command.player_index) or nil

        if player and player.valid and not player.admin then
            player.print("Only admins can use /wdm-reset-crystal-bonuses.")
            return
        end

        local ok, old_melee_bonus, old_biological_bonus = pcall(function()
            return planetary_events.reset_crystal_mined_bonuses()
        end)

        if not ok then
            local message = "Failed to reset crystal mined bonuses."
            if player and player.valid then
                player.print(message)
            else
                log(message)
            end
            log("[WDM Expansion] " .. tostring(old_melee_bonus))
            return
        end

        local message = string.format(
            "Crystal mined bonuses reset. Old values: melee %.2f%%, biological %.2f%%.",
            (old_melee_bonus or 0) * 100,
            (old_biological_bonus or 0) * 100
        )

        if player and player.valid then
            player.print(message)
            return
        end

        log(message)
    end)
end

return mod_commands
