local emergency_return = {}

local safe_teleport_finder = nil

local function is_debug_enabled()
    if not settings.global then return false end
    local setting = settings.global["wdm-expansion-debug"]
    if setting then return setting.value end
    return false
end

local function debug(msg)
    if not game then return end
    if not is_debug_enabled() then return end
    log("[WDM Expansion DEBUG] " .. msg)
    for _, p in pairs(game.connected_players) do
        p.print("[WDM Expansion DEBUG] " .. msg)
    end
end

function emergency_return.init(opts)
    opts = opts or {}
    safe_teleport_finder = opts.find_safe_teleport_position
end

local function get_safe_position(surface, preferred_pos)
    if safe_teleport_finder then
        return safe_teleport_finder(surface, preferred_pos)
    end
    return preferred_pos
end

local function is_real_tile(surface, position)
    if not (surface and surface.valid and position) then return false end
    local ok, tile = pcall(function()
        return surface.get_tile(position)
    end)
    if not (ok and tile and tile.valid and tile.name) then return false end
    return tile.name ~= "out-of-map"
end

local BASE_INVENTORY_LOSS_PERCENT = 50
local LOSS_REDUCTION_PER_QUALITY_LEVEL = 5

local function get_capsule_inventory_loss_percent(quality)
    local quality_level = 0

    if quality and quality.valid and quality.level then
        quality_level = tonumber(quality.level) or 0
    elseif type(quality) == "table" then
        quality_level = tonumber(quality.level) or 0
    elseif type(quality) == "string" then
        local qproto = prototypes and prototypes.quality and prototypes.quality[quality]
        if qproto and qproto.level then
            quality_level = tonumber(qproto.level) or 0
        end
    end

    local loss_percent = BASE_INVENTORY_LOSS_PERCENT - (quality_level * LOSS_REDUCTION_PER_QUALITY_LEVEL)
    if loss_percent < 0 then
        loss_percent = 0
    end
    return loss_percent
end

function emergency_return.on_player_used_capsule(event)
    if not event.item or event.item.name ~= "emergency-return" then return end
    if not event.player_index then return end

    local player = game.get_player(event.player_index)
    if not (player and player.character and player.character.valid) then return end

    local ship_surface = nil
    local ship_position = nil
    local force = player.force

    if force and force.name then
        for i = 0, 6 do
            local surf_name = "ship_interior_" .. i .. "_" .. force.name
            local surf = game.surfaces[surf_name]
            if surf and surf.valid then
                local lost = storage.lost_decks and storage.lost_decks[surf.index]
                if not (lost and lost.end_tick and game.tick < lost.end_tick) then
                    local spawn_pos = force.get_spawn_position(surf)
                    if spawn_pos and is_real_tile(surf, spawn_pos) then
                        ship_surface = surf
                        ship_position = spawn_pos
                        break
                    end
                end
            end
        end

        if not ship_surface and remote.interfaces["WDM"] then
            pcall(function()
                local planet_info = remote.call("WDM", "get_ship_planet_info", force.name)
                if planet_info then
                    for i = 0, 6 do
                        local surf_name = "ship_interior_" .. i .. "_" .. force.name
                        local surf = game.surfaces[surf_name]
                        if surf and surf.valid then
                            local lost = storage.lost_decks and storage.lost_decks[surf.index]
                            if not (lost and lost.end_tick and game.tick < lost.end_tick) then
                                local spawn_pos = force.get_spawn_position(surf)
                                if spawn_pos and is_real_tile(surf, spawn_pos) then
                                    ship_surface = surf
                                    ship_position = spawn_pos
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    if not (ship_surface and ship_surface.valid and ship_position) then
        player.print({"wdm-expansion.emergency_recall_no_ship"})
        return
    end

    local loss_percent = get_capsule_inventory_loss_percent(event.quality)

    local inventory = player.get_inventory(defines.inventory.character_main)
    if inventory and inventory.valid then
        local items_to_remove = {}
        local total_items = 0

        for i = 1, #inventory do
            local stack = inventory[i]
            if stack and stack.valid and stack.valid_for_read and stack.count > 0 then
                local name = stack.name
                local count = stack.count
                if name and count and count > 0 then
                    total_items = total_items + count
                    table.insert(items_to_remove, {name = name, count = count})
                end
            end
        end

        if total_items > 0 then
            local items_to_delete = math.floor(total_items * (loss_percent / 100))
            local deleted = 0

            while deleted < items_to_delete and #items_to_remove > 0 do
                local idx = math.random(#items_to_remove)
                local item = items_to_remove[idx]
                local remove_count = math.min(item.count, items_to_delete - deleted)

                if remove_count > 0 then
                    inventory.remove({name = item.name, count = remove_count})
                    deleted = deleted + remove_count

                    if item.count - remove_count > 0 then
                        item.count = item.count - remove_count
                    else
                        table.remove(items_to_remove, idx)
                    end
                else
                    table.remove(items_to_remove, idx)
                end
            end
        end
    end

    if ship_surface and ship_surface.valid and ship_position then
        local safe_pos = get_safe_position(ship_surface, ship_position)
        if safe_pos and is_real_tile(ship_surface, safe_pos) then
            player.teleport(safe_pos, ship_surface)
            player.print({"wdm-expansion.emergency_recall_success_quality", loss_percent})
            debug("Player " .. player.name .. " used emergency recall, teleported to ship")
        else
            player.print({"wdm-expansion.emergency_recall_no_ship"})
        end
    end
end

return emergency_return
