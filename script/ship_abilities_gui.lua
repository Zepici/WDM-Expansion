local ship_abilities_gui = {}
local ship_abilities = require("script.ship_abilities")

-- Структура: { [player_index] = { frame = ..., elements = { [ability_name] = { button = ..., cd_label = ... }, ... }, chest_status = ... } }
local gui_cache = {}
local gui_ticker_registered = false
local ABILITIES_CONFIG = ship_abilities.get_abilities_config()

-- Главный GUI-тиккер
local function gui_tick_handler()
    for player_index, cache in pairs(gui_cache) do
        local player = game.get_player(player_index)
        if not player or not player.valid then
            gui_cache[player_index] = nil
            goto continue
        end
        
        local frame = cache.frame
        if not frame or not frame.valid then
            gui_cache[player_index] = nil
            goto continue
        end
        
        local force = player.force
        if not force or not force.valid then
            goto continue
        end
        
        local force_name = force.name
        
        -- Обновляем данные
        for ability_name, element_refs in pairs(cache.elements) do
            local config = ABILITIES_CONFIG[ability_name]
            if not config then goto continue_ability end
            
            local is_unlocked = ship_abilities.is_ability_unlocked(force, ability_name)
            local was_unlocked = element_refs.was_unlocked
            
            -- Пропускаем скрытые строки, если статус разблокировки не менялся
            if not is_unlocked and was_unlocked == false then
                goto continue_ability
            end
            
            local cooldown_remaining = ship_abilities.get_ability_cooldown_remaining(force_name, ability_name)
            local was_cd = element_refs.was_cooldown
            local changed = (is_unlocked ~= was_unlocked) or (cooldown_remaining ~= was_cd)
            
            -- Пропускаем, если ничего не изменилось
            if not changed then
                goto continue_ability
            end
            
            -- Обновляем кеш
            element_refs.was_unlocked = is_unlocked
            element_refs.was_cooldown = cooldown_remaining
            
            -- Обновляем видимость строки
            local row_frame = element_refs.row_frame
            if row_frame and row_frame.valid then
                local new_visible = is_unlocked
                if row_frame.visible ~= new_visible then
                    row_frame.visible = new_visible
                end
            end
            
            -- Обновляем кнопку активации
            local button = element_refs.button
            if button and button.valid then
                local uses_remaining = ship_abilities.get_ability_uses_remaining(force_name, ability_name)
                local has_uses = uses_remaining == nil or uses_remaining > 0
                
                if is_unlocked then
                    if button.caption ~= {"wdm-expansion.ability-button-activate"} then
                        button.caption = {"wdm-expansion.ability-button-activate"}
                    end
                else
                    if button.caption ~= {"wdm-expansion.ability-button-locked"} then
                        button.caption = {"wdm-expansion.ability-button-locked"}
                    end
                end
                
                local new_enabled = is_unlocked and cooldown_remaining == 0 and has_uses
                if button.enabled ~= new_enabled then
                    button.enabled = new_enabled
                end
                
                local new_style = is_unlocked and (has_uses and "confirm_button" or "red_back_button") or "red_back_button"
                if button.style ~= new_style then
                    button.style = new_style
                end
                
                -- Обновляем tooltip только при изменении
                if not is_unlocked then
                    button.tooltip = {"wdm-expansion.ship-ability-not-unlocked"}
                elseif not has_uses then
                    button.tooltip = {"wdm-expansion.ship-ability-max-uses-reached", config.max_uses_per_warp}
                elseif cooldown_remaining > 0 then
                    button.tooltip = {"wdm-expansion.ship-ability-on-cooldown", math.ceil(cooldown_remaining / 60)}
                else
                    button.tooltip = config.localised_desc
                end
            end
            
            -- Обновляем лейбл кулдауна
            local cd_label = element_refs.cd_label
            if cd_label and cd_label.valid then
                if cooldown_remaining > 0 then
                    cd_label.caption = {"", {"wdm-expansion.cooldown-label"}, ": ", math.ceil(cooldown_remaining / 60), "s"}
                    cd_label.style.font_color = {r = 1, g = 0.3, b = 0.3}
                    cd_label.style.font = "default-bold"
                else
                    cd_label.caption = {"", {"wdm-expansion.cooldown-label"}, ": 0s"}
                    cd_label.style.font_color = {r = 0.5, g = 0.5, b = 0.5}
                    cd_label.style.font = "default"
                end
            end
            
            -- Обновляем лейбл оставшихся использований
            local uses_label = element_refs.uses_label
            if uses_label and uses_label.valid then
                local uses_remaining = ship_abilities.get_ability_uses_remaining(force_name, ability_name)
                local max_uses = config.max_uses_per_warp
                if uses_remaining ~= nil then
                    uses_label.caption = {"wdm-expansion.ability-uses-remaining-formatted", uses_remaining, max_uses}
                    if uses_remaining == 0 then
                        uses_label.style.font_color = {r = 1, g = 0.3, b = 0.3}
                    else
                        uses_label.style.font_color = {r = 0.4, g = 0.9, b = 0.4}
                    end
                end
            end
            
            ::continue_ability::
        end
        
        -- Обновляем статус сундука (resource_collector) только если GUI был открыт недавно
        -- т.к эта информация меняется только по действию игрока
        if cache.chest_status and cache.chest_status.valid then
            local chest_info = ship_abilities.get_target_chest_info(force_name)
            if chest_info and not chest_info.lost then
                cache.chest_status.caption = {"wdm-expansion.resource-collector-target-selected", chest_info.name, chest_info.surface}
            elseif chest_info and chest_info.lost then
                cache.chest_status.caption = {"wdm-expansion.resource-collector-target-selected", chest_info.name, chest_info.surface}
            else
                cache.chest_status.caption = {"wdm-expansion.resource-collector-target-not-selected"}
            end
        end
        
        -- Обновляем статус выбранного предмета (waste_recycler) только если GUI был открыт недавно
        if cache.waste_recycler_item_label and cache.waste_recycler_item_label.valid then
            local item = ship_abilities.get_waste_recycler_item(force_name)
            if item and item.name then
                cache.waste_recycler_item_label.caption = {"wdm-expansion.waste-recycler-current-item", item.name}
            else
                cache.waste_recycler_item_label.caption = {"wdm-expansion.waste-recycler-no-item-selected"}
            end
        end
        
        ::continue::
    end
    
    -- Если ничего нет
    if not next(gui_cache) and gui_ticker_registered then
        script.on_nth_tick(61, nil)
        gui_ticker_registered = false
        log("[wdm-expansion] GUI ticker disabled - no open GUIs")
    end
end

-- Управление включением тикера
local function ensure_gui_ticker()
    if not gui_ticker_registered then
        script.on_nth_tick(61, gui_tick_handler)
        gui_ticker_registered = true
        log("[wdm-expansion] GUI ticker enabled")
    end
end


-- Функция для открытия GUI консоли способностей
function ship_abilities_gui.open_console(player, console_entity)
    if not player or not player.valid then return end
    
    if gui_cache[player.index] then
        if gui_cache[player.index].frame and gui_cache[player.index].frame.valid then
            gui_cache[player.index].frame.destroy()
        end
        gui_cache[player.index] = nil
    end
    
    -- Главный фрейм
    local frame = player.gui.screen.add({
        type = "frame",
        name = "wdm_ship_abilities_frame",
        direction = "vertical"
    })
    frame.auto_center = true
    frame.style.width = 720
    
    player.opened = frame
    
    ------------------------------------------------------------------------
    -- ЗАГОЛОВОК ОКНА
    ------------------------------------------------------------------------
    local title_bar = frame.add({type = "flow", direction = "horizontal"})
    title_bar.style.horizontally_stretchable = true
    title_bar.style.bottom_padding = 4
    
    title_bar.add({
        type = "label", 
        caption = {"entity-name.wdm-ship-abilities-console"}, 
        style = "frame_title"
    })
    
    local drag_handle = title_bar.add({type = "empty-widget", style = "draggable_space_header"})
    drag_handle.style.horizontally_stretchable = true
    drag_handle.style.vertically_stretchable = true
    drag_handle.drag_target = frame
    
    title_bar.add({
        type = "sprite-button", 
        name = "wdm-abilities-close", 
        sprite = "utility/close", 
        style = "frame_action_button"
    })
    
    ------------------------------------------------------------------------
    -- КОНТЕНТ
    ------------------------------------------------------------------------
    local inside_frame = frame.add({type = "frame", direction = "vertical", style = "inside_deep_frame"})
    
    local sub_header_flow = inside_frame.add({type = "flow", direction = "horizontal"})
    sub_header_flow.style.left_padding = 12
    sub_header_flow.style.top_padding = 6
    sub_header_flow.style.bottom_padding = 6
    
    sub_header_flow.add({
        type = "label", 
        caption = {"wdm-expansion.ship-abilities-header"}
    })
    
    inside_frame.add({type = "line", direction = "horizontal"})
    
    local scroll = inside_frame.add({
        type = "scroll-pane", 
        name = "wdm-abilities-scroll",
        direction = "vertical"
    })
    scroll.style.maximal_height = 550
    scroll.style.horizontally_stretchable = true
    
    local abilities_table = scroll.add({type = "table", column_count = 1})
    abilities_table.style.horizontally_stretchable = true
    abilities_table.style.vertical_spacing = 8
    
    -- Подготавливаем кеш
    local cache = {
        frame = frame,
        elements = {},
        chest_status = nil
    }
    gui_cache[player.index] = cache
    
    for ability_name, config in pairs(ABILITIES_CONFIG) do
        local force = player.force
        local is_unlocked = force and force.valid and ship_abilities.is_ability_unlocked(force, ability_name)
        local cooldown_remaining = force and force.valid and ship_abilities.get_ability_cooldown_remaining(force.name, ability_name) or 0
        
        local row_frame = abilities_table.add({
            type = "frame", 
            direction = "horizontal"
        })
        row_frame.name = "wdm-ability-row-" .. ability_name
        row_frame.style.width = 680 
        row_frame.style.vertical_align = "center"
        row_frame.style.padding = 12
        
        ------------------------------------------------------------------------
        -- ЛЕВАЯ ЧАСТЬ
        ------------------------------------------------------------------------
        local info_flow = row_frame.add({type = "flow", direction = "vertical"})
        info_flow.style.width = 460 
        info_flow.style.right_padding = 15
        
        local title_label = info_flow.add({
            type = "label", 
            caption = config.localised_name
        })
        title_label.style.font = "default-bold"
        
        local desc_label = info_flow.add({
            type = "label", 
            caption = config.localised_desc
        })
        desc_label.style.single_line = false
        desc_label.style.top_padding = 4
        desc_label.style.bottom_padding = 4
        desc_label.style.font_color = {r = 0.75, g = 0.75, b = 0.75}

        if ability_name == "resource_collector" then
            local chest_info = ship_abilities.get_target_chest_info(force.name)
            local chest_status_text = chest_info 
                and {"wdm-expansion.resource-collector-target-selected", chest_info.name, chest_info.surface}
                or {"wdm-expansion.resource-collector-target-not-selected"}
            
            local chest_flow = info_flow.add({type = "flow", direction = "horizontal"})
            chest_flow.style.vertical_align = "center"
            chest_flow.style.top_padding = 4
            chest_flow.style.bottom_padding = 4
            
            local status_label = chest_flow.add({
                type = "label",
                name = "wdm-chest-status",
                caption = chest_status_text
            })
            status_label.style.font_color = chest_info and {r = 0.4, g = 0.9, b = 0.4} or {r = 1, g = 0.6, b = 0.1}
            cache.chest_status = status_label
            
            local select_btn = chest_flow.add({
                type = "button",
                name = "wdm-open-chest-selector",
                caption = {"wdm-expansion.chest-selector-button"}
            })
        end
        
        if ability_name == "waste_recycler" then
            local item = ship_abilities.get_waste_recycler_item(force.name)
            local item_label_text = item and item.name 
                and {"wdm-expansion.waste-recycler-current-item", item.name}
                or {"wdm-expansion.waste-recycler-no-item-selected"}
            
            local recycle_flow = info_flow.add({type = "flow", direction = "horizontal"})
            recycle_flow.style.vertical_align = "center"
            recycle_flow.style.top_padding = 4
            recycle_flow.style.bottom_padding = 4
            
            local item_label = recycle_flow.add({
                type = "label",
                name = "wdm-waste-recycler-item-label",
                caption = item_label_text
            })
            item_label.style.right_padding = 10
            cache.waste_recycler_item_label = item_label
            
            local pick_btn = recycle_flow.add({
                type = "choose-elem-button",
                name = "wdm-waste-recycler-pick-item",
                elem_type = "item",
                elem_value = item and item.name or nil
            })
            pick_btn.tooltip = {"wdm-expansion.waste-recycler-item-pick"}
        end
        
        ------------------------------------------------------------------------
        -- ПРАВАЯ ЧАСТЬ
        ------------------------------------------------------------------------
        local controls_flow = row_frame.add({type = "flow", direction = "vertical"})
        controls_flow.style.width = 170 
        controls_flow.style.horizontal_align = "right"
        controls_flow.style.vertical_spacing = 4
        
        controls_flow.add({
            type = "label", 
            caption = {"", {"wdm-expansion.warponium-cost-label"}, "[font=default-bold][color=purple]: ", config.cost_fluid, "[/color][/font]"}
        })
        
        -- Лейбл кулдауна (всегда создаётся для автообновления)
        local cd_label = controls_flow.add({
            type = "label",
            name = "wdm-cd-label-" .. ability_name,
            caption = cooldown_remaining > 0 
                and {"", {"wdm-expansion.cooldown-label"}, ": ", math.ceil(cooldown_remaining / 60), "s"}
                or {"", {"wdm-expansion.cooldown-label"}, ": 0s"}
        })
        if cooldown_remaining > 0 then
            cd_label.style.font_color = {r = 1, g = 0.3, b = 0.3}
            cd_label.style.font = "default-bold"
        else
            cd_label.style.font_color = {r = 0.5, g = 0.5, b = 0.5}
            cd_label.style.font = "default"
        end
        
        -- Лейбл оставшихся использований за варп
        local uses_remaining = ship_abilities.get_ability_uses_remaining(force.name, ability_name)
        local max_uses = config.max_uses_per_warp
        local uses_label = controls_flow.add({
            type = "label",
            name = "wdm-uses-label-" .. ability_name,
            caption = uses_remaining ~= nil 
                and {"wdm-expansion.ability-uses-remaining-formatted", uses_remaining, max_uses}
                or {"wdm-expansion.ability-no-uses-limit"}
        })
        if uses_remaining ~= nil then
            if uses_remaining == 0 then
                uses_label.style.font_color = {r = 1, g = 0.3, b = 0.3}
            else
                uses_label.style.font_color = {r = 0.4, g = 0.9, b = 0.4}
            end
            uses_label.style.font = "default"
        else
            uses_label.style.font_color = {r = 0.5, g = 0.5, b = 0.5}
        end
        
        local has_uses = uses_remaining == nil or uses_remaining > 0
        local button = controls_flow.add({
            type = "button",
            name = "wdm-ability-button-" .. ability_name, 
            caption = is_unlocked and {"wdm-expansion.ability-button-activate"} or {"wdm-expansion.ability-button-locked"},
            enabled = is_unlocked and cooldown_remaining == 0 and has_uses,
            style = is_unlocked and (has_uses and "confirm_button" or "red_back_button") or "red_back_button"
        })
        button.style.width = 150 
        
        if not is_unlocked then
            button.tooltip = {"wdm-expansion.ship-ability-not-unlocked"}
        elseif not has_uses then
            button.tooltip = {"wdm-expansion.ship-ability-max-uses-reached", config.max_uses_per_warp}
        elseif cooldown_remaining > 0 then
            button.tooltip = {"wdm-expansion.ship-ability-on-cooldown", math.ceil(cooldown_remaining / 60)}
        else
            button.tooltip = config.localised_desc
        end
        
        if not is_unlocked then
            row_frame.visible = false
        end
        
        cache.elements[ability_name] = {
            button = button,
            cd_label = cd_label,
            uses_label = uses_label,
            row_frame = row_frame,
            was_unlocked = is_unlocked,
            was_cooldown = cooldown_remaining
        }
    end
    
    -- Регистрируем игрока для автообновления
    ensure_gui_ticker()
end

-- Вспомогательная функция: найти и уничтожить фрейм GUI у игрока (по экрану)
local function destroy_player_frame(player)
    if not player or not player.valid then return end
    if not player.gui or not player.gui.screen then return end
    
    local frame = player.gui.screen["wdm_ship_abilities_frame"]
    if frame and frame.valid then
        frame.destroy()
    end
    
    if gui_cache[player.index] then
        gui_cache[player.index] = nil
    end
end

-- Функция для открытия режима выбора целевого сундука
function ship_abilities_gui.start_chest_selection_mode(player)
    if not player or not player.valid then return end
    
    ship_abilities.start_chest_selection_mode(player.index)
    
    destroy_player_frame(player)
    
    player.print({"wdm-expansion.chest-selector-click-on-chest"})
end

-- Обработчик клика по элементам главного GUI
function ship_abilities_gui.on_gui_click(event)
    if not event or not event.element or not event.player_index then return end
    
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    
    local element = event.element
    
    if element.name == "wdm-abilities-close" then
        destroy_player_frame(player)
    elseif element.name == "wdm-open-chest-selector" then
        ship_abilities_gui.start_chest_selection_mode(player)
    else
        ship_abilities.on_gui_click(event)
    end
end

-- Обработчик изменения элемента выбора (choose-elem-button)
function ship_abilities_gui.on_gui_elem_changed(event)
    if not event or not event.element or not event.player_index then return end
    
    local element = event.element
    if element.name ~= "wdm-waste-recycler-pick-item" then return end
    
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    
    local force = player.force
    if not force or not force.valid then return end
    
    local elem_value = element.elem_value
    if elem_value then
        ship_abilities.set_waste_recycler_item(force.name, elem_value)
        log("[wdm-expansion] Waste recycler item selected: " .. elem_value)
    else
        ship_abilities.set_waste_recycler_item(force.name, nil)
        log("[wdm-expansion] Waste recycler item cleared")
    end
end

-- Обработчик закрытия GUI
function ship_abilities_gui.on_gui_closed(event)
    if not event or not event.player_index then return end
    
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    
    -- Закрытие по E/Esc (когда player.opened установлен на наш frame)
    if event.gui_type == defines.gui_type.custom then
        destroy_player_frame(player)
        return
    end
    
    -- Закрытие через открытие другого GUI
    if event.gui_type == defines.gui_type.entity and event.entity and event.entity.name == "wdm-ship-abilities-console" then
        destroy_player_frame(player)
    end
end

-- Очистка GUI при загрузке: удаляем висячие фреймы и сбрасываем кеш
function ship_abilities_gui.on_load()

    gui_cache = {}
    gui_ticker_registered = false
    
    if game and game.players then
        for _, player in pairs(game.players) do
            if player.valid and player.gui and player.gui.screen then
                local frame = player.gui.screen["wdm_ship_abilities_frame"]
                if frame and frame.valid then
                    frame.destroy()
                end
            end
        end
    end
end

return ship_abilities_gui