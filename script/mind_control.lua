local mind_control = {}

local CONTROL_DURATION = 15 * 60
local ENEMY_SPAWN_INTERVAL = 9999
local CONTROL_EFFECT_ID = "wdm-mind-control-effect"
local TICK_HANDLER_REGISTERED = false

local math_random = math.random
local math_cos = math.cos
local math_sin = math.sin
local math_abs = math.abs
local math_pi = math.pi

local directions = {
    defines.direction.north,
    defines.direction.northeast,
    defines.direction.east,
    defines.direction.southeast,
    defines.direction.south,
    defines.direction.southwest,
    defines.direction.west,
    defines.direction.northwest
}

-- Кэш типов построек для фильтрации find_entities_filtered
local structure_types_filter = {
    "ammo-turret", 
    "artillery-turret", 
    "fluid-turret", 
    "laser-turret", 
    "radar", 
    "assembling-machine", 
    "furnace", 
    "solar-panel", 
    "accumulator"
}

local function init_storage()
    if not storage.mind_controlled_players then
        storage.mind_controlled_players = {}
    end
    if not storage.mind_controlled_spiders then
        storage.mind_controlled_spiders = {}
    end
    if not storage.mind_controlled_cars then
        storage.mind_controlled_cars = {}
    end
end

local function check_and_sync_tick_handler()
    local has_controlled_players = next(storage.mind_controlled_players or {}) ~= nil
    local has_controlled_spiders = next(storage.mind_controlled_spiders or {}) ~= nil
    local has_controlled_cars = next(storage.mind_controlled_cars or {}) ~= nil
    
    local has_controlled = has_controlled_players or has_controlled_spiders or has_controlled_cars

    if has_controlled and not TICK_HANDLER_REGISTERED then
        script.on_nth_tick(1, mind_control.on_nth_tick)
        TICK_HANDLER_REGISTERED = true

    elseif not has_controlled and TICK_HANDLER_REGISTERED then
        script.on_nth_tick(1, nil)
        TICK_HANDLER_REGISTERED = false
    end
end

local function find_gun_with_ammo(character, current_gun_index)
    if not character or not character.valid or character.type ~= "character" then
        return current_gun_index
    end

    local ammo_id = defines.inventory.character_ammo or 4
    local gun_id = defines.inventory.character_guns or defines.inventory.character_gun or 3

    local ammo_inv = character.get_inventory(ammo_id)
    local gun_inv = character.get_inventory(gun_id)
    
    if not ammo_inv or not gun_inv or not ammo_inv.valid or not gun_inv.valid then 
        return current_gun_index 
    end

    if ammo_inv[current_gun_index] and ammo_inv[current_gun_index].valid_for_read 
       and gun_inv[current_gun_index] and gun_inv[current_gun_index].valid_for_read then
        return current_gun_index
    end

    local total_slots = #ammo_inv
    for i = 1, total_slots do
        if ammo_inv[i] and ammo_inv[i].valid_for_read 
           and gun_inv[i] and gun_inv[i].valid_for_read then
            return i 
        end
    end

    return current_gun_index
end

local function on_script_trigger_effect(event)
    if event.effect_id ~= CONTROL_EFFECT_ID then
        return
    end

    local target = event.target_entity
    if not target or not target.valid then
        return
    end

    init_storage()

    -------------------------------------------------------------------
    -- ТРИГГЕР: ИГРОК
    -------------------------------------------------------------------
    if target.type == "character" then
        local player = target.player
        if not player then
            return
        end

        if storage.mind_controlled_players[player.index] then
            storage.mind_controlled_players[player.index].end_tick =
                event.tick + CONTROL_DURATION
            return
        end

        local connected = game.connected_players
        local multiplayer_mode = (#connected > 1)
        local original_force_name = player.force.name
        
        local character_entity = player.character
        if not character_entity then
            return
        end

        local initial_gun_index = find_gun_with_ammo(character_entity, character_entity.selected_gun_index)

        if multiplayer_mode then
            player.force = "enemy"
            player.print(
                {"wdm-expansion.mind-control-activated"},
                {r = 1, g = 0, b = 0}
            )
        else
            player.force = "enemy"
            player.print(
                {"wdm-expansion.mind-control-activated"},
                {r = 1, g = 0.2, b = 0.8}
            )
        end

        player.opened = nil

        storage.mind_controlled_players[player.index] = {
            end_tick = event.tick + CONTROL_DURATION,
            spawn_counter = 0,
            direction_tick = 0,
            current_direction = directions[math_random(1, #directions)],
            original_force = original_force_name,
            is_multiplayer = multiplayer_mode,
            target_update_tick = 0,
            last_target_pos = nil,
            character = character_entity,
            locked_gun_index = initial_gun_index
        }

    -------------------------------------------------------------------
    -- ТРИГГЕР: SPIDER-VEHICLE
    -------------------------------------------------------------------
    elseif target.type == "spider-vehicle" then
        local unit_number = target.unit_number
        if not unit_number then 
            return 
        end

        if storage.mind_controlled_spiders[unit_number] then
            storage.mind_controlled_spiders[unit_number].end_tick =
                event.tick + CONTROL_DURATION
            return
        end

        local original_force_name = target.force.name
        local connected = game.connected_players
        local multiplayer_mode = (#connected > 1)

        target.force = "enemy"

        storage.mind_controlled_spiders[unit_number] = {
            entity = target,
            end_tick = event.tick + CONTROL_DURATION,
            spawn_counter = 0,
            direction_tick = 0,
            current_direction = directions[math_random(1, #directions)],
            original_force = original_force_name,
            is_multiplayer = multiplayer_mode,
            target_update_tick = 0,
            last_target_pos = nil
        }

    -------------------------------------------------------------------
    -- ТРИГГЕР: МАШИНЫ И ТАНКИ (тип "car")
    -------------------------------------------------------------------
    elseif target.type == "car" then
        local unit_number = target.unit_number
        if not unit_number then 
            return 
        end

        if storage.mind_controlled_cars[unit_number] then
            storage.mind_controlled_cars[unit_number].end_tick =
                event.tick + CONTROL_DURATION
            return
        end

        local original_force_name = target.force.name
        local connected = game.connected_players
        local multiplayer_mode = (#connected > 1)

        target.force = "enemy"

        storage.mind_controlled_cars[unit_number] = {
            entity = target,
            end_tick = event.tick + CONTROL_DURATION,
            spawn_counter = 0,
            direction_tick = 0,
            current_turn = 1,
            current_direction = directions[math_random(1, #directions)],
            original_force = original_force_name,
            is_multiplayer = multiplayer_mode,
            target_update_tick = 0,
            last_target_pos = nil
        }
    end

    check_and_sync_tick_handler()
end

-- тик-обработчик
local function on_nth_tick(event)
    init_storage()

    local current_tick = game.tick
    local to_remove_players = {}
    local to_remove_spiders = {}
    local to_remove_cars = {}
    
    local connected_players = game.connected_players

    -------------------------------------------------------------------
    -- ОБРАБОТКА ИГРОКОВ
    -------------------------------------------------------------------
    for player_index, control_data in pairs(storage.mind_controlled_players) do
        local player = game.get_player(player_index)

        if not player or not player.valid then
            table.insert(to_remove_players, player_index)
            goto continue_player
        end

        local character = player.character

        if not character or not character.valid then
            table.insert(to_remove_players, player_index)
            goto continue_player
        end

        if current_tick >= control_data.end_tick then
            table.insert(to_remove_players, player_index)

            player.print(
                {"wdm-expansion.mind-control-ended"},
                {r = 0.2, g = 1, b = 0.8}
            )

            goto continue_player
        end

        player.opened = nil
        
        if (current_tick % 600 == 0) then
            control_data.locked_gun_index = find_gun_with_ammo(character, control_data.locked_gun_index)
        end

        if control_data.locked_gun_index then
            character.selected_gun_index = control_data.locked_gun_index
        end

        local char_pos = character.position

        if control_data.is_multiplayer then
            if current_tick >= control_data.target_update_tick then
                control_data.target_update_tick = current_tick + 10
                control_data.last_target_pos = nil

                local min_dist = 999999
                local target_char = nil

                for _, p in pairs(connected_players) do
                    if
                        p.index ~= player_index and
                        p.character and
                        p.character.valid and
                        not storage.mind_controlled_players[p.index]
                    then
                        local p_pos = p.character.position

                        local approx_dist =
                            math_abs(p_pos.x - char_pos.x) +
                            math_abs(p_pos.y - char_pos.y)

                        if approx_dist < min_dist then
                            min_dist = approx_dist
                            target_char = p.character
                        end
                    end
                end

                if target_char then
                    control_data.last_target_pos = target_char.position
                else
                    local structures = character.surface.find_entities_filtered({
                        position = char_pos,
                        radius = 40,
                        force = control_data.original_force,
                        type = structure_types_filter,
                        limit = 1
                    })

                    if #structures > 0 then
                        control_data.last_target_pos =
                            structures.position
                    end
                end
            end

            local target_pos = control_data.last_target_pos
            if target_pos then
                local dx = target_pos.x - char_pos.x
                local dy = target_pos.y - char_pos.y

                local direction = defines.direction.north

                if math_abs(dx) > math_abs(dy) then
                    direction =
                        (dx > 0)
                        and defines.direction.east
                        or defines.direction.west
                else
                    direction =
                        (dy > 0)
                        and defines.direction.south
                        or defines.direction.north
                end

                character.walking_state = {
                    walking = true,
                    direction = direction
                }

                local ammo_id = defines.inventory.character_ammo or 4
                local ammo_inv = character.get_inventory(ammo_id)
                if ammo_inv and ammo_inv[character.selected_gun_index] and ammo_inv[character.selected_gun_index].valid_for_read then
                    character.shooting_state = {
                        state = defines.shooting.shooting_enemies,
                        position = {
                            x = target_pos.x,
                            y = target_pos.y
                        }
                    }
                else
                    character.shooting_state = {
                        state = defines.shooting.not_shooting
                    }
                end
            else
                character.walking_state = {
                    walking = false
                }

                character.shooting_state = {
                    state = defines.shooting.not_shooting
                }
            end

        else
            if current_tick >= control_data.direction_tick then
                control_data.current_direction =
                    directions[math_random(1, #directions)]

                control_data.direction_tick = current_tick + 30
            end

            character.walking_state = {
                walking = true,
                direction = control_data.current_direction
            }

            local dir = control_data.current_direction
            local sx, sy = 0, 0

            if dir == defines.direction.north then
                sy = -5
            elseif dir == defines.direction.northeast then
                sx = 5
                sy = -5
            elseif dir == defines.direction.east then
                sx = 5
            elseif dir == defines.direction.southeast then
                sx = 5
                sy = 5
            elseif dir == defines.direction.south then
                sy = 5
            elseif dir == defines.direction.southwest then
                sx = -5
                sy = 5
            elseif dir == defines.direction.west then
                sx = -5
            elseif dir == defines.direction.northwest then
                sx = -5
                sy = -5
            end

            local ammo_id = defines.inventory.character_ammo or 4
            local ammo_inv = character.get_inventory(ammo_id)
            if ammo_inv and ammo_inv[character.selected_gun_index] and ammo_inv[character.selected_gun_index].valid_for_read then
                character.shooting_state = {
                    state = defines.shooting.shooting_enemies,
                    position = {
                        x = char_pos.x + sx,
                        y = char_pos.y + sy
                    }
                }
            else
                character.shooting_state = {
                    state = defines.shooting.not_shooting
                }
            end
        end

        control_data.spawn_counter =
            control_data.spawn_counter + 1

        if control_data.spawn_counter >= ENEMY_SPAWN_INTERVAL then
            control_data.spawn_counter = 0

            local angle =
                (current_tick / 60) % (2 * math_pi)

            local enemy_pos = {
                x = char_pos.x + math_cos(angle) * 20,
                y = char_pos.y + math.sin(angle) * 20
            }

            local surface = character.surface

            if surface.can_place_entity({
                name = "medium-biter",
                position = enemy_pos
            }) then
                surface.create_entity({
                    name = "medium-biter",
                    position = enemy_pos,
                    force = "enemy"
                })
            end
        end

        ::continue_player::
    end

    -------------------------------------------------------------------
    -- ОБРАБОТКА SPIDER-VEHICLE
    -------------------------------------------------------------------
    for unit_number, control_data in pairs(storage.mind_controlled_spiders) do
        local spider = control_data.entity

        if not spider or not spider.valid then
            table.insert(to_remove_spiders, unit_number)
            goto continue_spider
        end

        if current_tick >= control_data.end_tick then
            table.insert(to_remove_spiders, unit_number)
            goto continue_spider
        end

        local spider_pos = spider.position

        if control_data.is_multiplayer then
            if current_tick >= control_data.target_update_tick then
                control_data.target_update_tick = current_tick + 10
                control_data.last_target_pos = nil

                local min_dist = 999999
                local target_ent = nil

                for _, p in pairs(connected_players) do
                    if
                        p.character and
                        p.character.valid and
                        not storage.mind_controlled_players[p.index]
                    then
                        local p_pos = p.character.position

                        local approx_dist =
                            math_abs(p_pos.x - spider_pos.x) +
                            math_abs(p_pos.y - spider_pos.y)

                        if approx_dist < min_dist then
                            min_dist = approx_dist
                            target_ent = p.character
                        end
                    end
                end

                if target_ent then
                    control_data.last_target_pos = target_ent.position
                else
                    local structures = spider.surface.find_entities_filtered({
                        position = spider_pos,
                        radius = 60,
                        force = control_data.original_force,
                        type = structure_types_filter,
                        limit = 1
                    })

                    if #structures > 0 then
                        control_data.last_target_pos =
                            structures.position
                    end
                end
            end

            local target_pos = control_data.last_target_pos
            if target_pos then
                spider.autopilot_destination = target_pos
            else
                spider.autopilot_destination = nil
            end

        else
            if current_tick >= control_data.direction_tick then
                control_data.current_direction =
                    directions[math_random(1, #directions)]

                control_data.direction_tick = current_tick + 60

                local sx, sy = 0, 0
                local dir = control_data.current_direction

                if dir == defines.direction.north then
                    sy = -15
                elseif dir == defines.direction.northeast then
                    sx = 15
                    sy = -15
                elseif dir == defines.direction.east then
                    sx = 15
                elseif dir == defines.direction.southeast then
                    sx = 15
                    sy = 15
                elseif dir == defines.direction.south then
                    sy = 15
                elseif dir == defines.direction.southwest then
                    sx = -15
                    sy = 15
                elseif dir == defines.direction.west then
                    sx = -15
                elseif dir == defines.direction.northwest then
                    sx = -15
                    sy = -15
                end

                spider.autopilot_destination = {
                    x = spider_pos.x + sx,
                    y = spider_pos.y + sy
                }
            end
        end

        control_data.spawn_counter =
            control_data.spawn_counter + 1

        if control_data.spawn_counter >= ENEMY_SPAWN_INTERVAL then
            control_data.spawn_counter = 0

            local angle =
                (current_tick / 60) % (2 * math_pi)

            local enemy_pos = {
                x = spider_pos.x + math_cos(angle) * 20,
                y = spider_pos.y + math.sin(angle) * 20
            }

            local surface = spider.surface

            if surface.can_place_entity({
                name = "medium-biter",
                position = enemy_pos
            }) then
                surface.create_entity({
                    name = "medium-biter",
                    position = enemy_pos,
                    force = "enemy"
                })
            end
        end

        ::continue_spider::
    end

    -------------------------------------------------------------------
    -- ОБРАБОТКА МАШИН И ТАНКОВ
    -------------------------------------------------------------------
    for unit_number, control_data in pairs(storage.mind_controlled_cars) do
        local car = control_data.entity

        if not car or not car.valid then
            table.insert(to_remove_cars, unit_number)
            goto continue_car
        end

        if current_tick >= control_data.end_tick then
            table.insert(to_remove_cars, unit_number)
            goto continue_car
        end

        local car_pos = car.position
        local car_orientation = car.orientation

        if control_data.is_multiplayer then
            if current_tick >= control_data.target_update_tick then
                control_data.target_update_tick = current_tick + 15
                control_data.last_target_pos = nil

                local min_dist = 999999
                local target_ent = nil

                for _, p in pairs(connected_players) do
                    if
                        p.character and
                        p.character.valid and
                        not storage.mind_controlled_players[p.index]
                    then
                        local p_pos = p.character.position

                        local approx_dist =
                            math_abs(p_pos.x - car_pos.x) +
                            math_abs(p_pos.y - car_pos.y)

                        if approx_dist < min_dist then
                            min_dist = approx_dist
                            target_ent = p.character
                        end
                    end
                end

                if target_ent then
                    control_data.last_target_pos = target_ent.position
                else
                    local structures = car.surface.find_entities_filtered({
                        position = car_pos,
                        radius = 60,
                        force = control_data.original_force,
                        type = structure_types_filter,
                        limit = 1
                    })

                    if #structures > 0 then
                        control_data.last_target_pos =
                            structures.position
                    end
                end
            end

            local target_pos = control_data.last_target_pos
            if target_pos then
                local angle_to_target =
                    math.atan2(target_pos.y - car_pos.y, target_pos.x - car_pos.x)

                local target_orientation =
                    (angle_to_target / (2 * math_pi)) + 0.25

                if target_orientation < 0 then
                    target_orientation = target_orientation + 1
                end

                local diff = target_orientation - car_orientation

                if diff > 0.5 then
                    diff = diff - 1
                elseif diff < -0.5 then
                    diff = diff + 1
                end

                local turn = defines.riding.direction.straight

                if diff > 0.05 then
                    turn = defines.riding.direction.right
                elseif diff < -0.05 then
                    turn = defines.riding.direction.left
                end

                car.riding_state = {
                    acceleration = defines.riding.acceleration.accelerating,
                    direction = turn
                }
            else
                car.riding_state = {
                    acceleration = defines.riding.acceleration.braking,
                    direction = defines.riding.direction.straight
                }
            end
        else
            if current_tick >= control_data.direction_tick then
                control_data.direction_tick =
                    current_tick + math_random(40, 90)

                control_data.current_turn = math_random(1, 3)
            end

            local turn = defines.riding.direction.straight

            if control_data.current_turn == 2 then
                turn = defines.riding.direction.left
            elseif control_data.current_turn == 3 then
                turn = defines.riding.direction.right
            end

            car.riding_state = {
                acceleration = defines.riding.acceleration.accelerating,
                direction = turn
            }
        end

        control_data.spawn_counter =
            control_data.spawn_counter + 1

        if control_data.spawn_counter >= ENEMY_SPAWN_INTERVAL then
            control_data.spawn_counter = 0

            local angle =
                (current_tick / 60) % (2 * math_pi)

            local enemy_pos = {
                x = car_pos.x + math_cos(angle) * 20,
                y = car_pos.y + math.sin(angle) * 20
            }

            local surface = car.surface

            if surface.can_place_entity({
                name = "medium-biter",
                position = enemy_pos
            }) then
                surface.create_entity({
                    name = "medium-biter",
                    position = enemy_pos,
                    force = "enemy"
                })
            end
        end

        ::continue_car::
    end

    -------------------------------------------------------------------
    -- ОЧИСТКА
    -------------------------------------------------------------------
    for _, player_index in pairs(to_remove_players) do
        local player = game.get_player(player_index)
        local data = storage.mind_controlled_players[player_index]

        if player and player.valid then
            if data and data.original_force then
                player.force = data.original_force
            end

            if player.character and player.character.valid then
                player.character.walking_state = {
                    walking = false,
                    direction = defines.direction.north
                }

                player.character.shooting_state = {
                    state = defines.shooting.not_shooting
                }
            end
        end

        storage.mind_controlled_players[player_index] = nil
    end

    for _, unit_number in pairs(to_remove_spiders) do
        local data = storage.mind_controlled_spiders[unit_number]

        if data and data.entity and data.entity.valid then
            data.entity.force = data.original_force
            data.entity.autopilot_destination = nil
        end

        storage.mind_controlled_spiders[unit_number] = nil
    end

    for _, unit_number in pairs(to_remove_cars) do
        local data = storage.mind_controlled_cars[unit_number]

        if data and data.entity and data.entity.valid then
            data.entity.force = data.original_force
            data.entity.riding_state = {
                acceleration = defines.riding.acceleration.nothing,
                direction = defines.riding.direction.straight
            }
        end

        storage.mind_controlled_cars[unit_number] = nil
    end

    if not next(storage.mind_controlled_players) then
        storage.mind_controlled_players = {}
    end
    if not next(storage.mind_controlled_spiders) then
        storage.mind_controlled_spiders = {}
    end
    if not next(storage.mind_controlled_cars) then
        storage.mind_controlled_cars = {}
    end

    check_and_sync_tick_handler()
end

local function on_init()
    init_storage()
    check_and_sync_tick_handler()
end

local function on_load()
    check_and_sync_tick_handler()
end

function mind_control.on_init()
    on_init()
end

function mind_control.on_load()
    on_load()
end

function mind_control.on_script_trigger_effect(event)
    on_script_trigger_effect(event)
end

function mind_control.on_nth_tick(event)
    on_nth_tick(event)
end

return mind_control
