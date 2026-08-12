return {
    {
        _base = data.raw["ammo-turret"]["kj_laser"],
        type = "electric-turret",
        name = "kj_electric_laser",
        energy_source = {
            type = "electric",
            buffer_capacity = "1500MJ",
            usage_priority = "primary-input",
            input_flow_limit = "10MW",
            drain = "0MW"
        },
        max_health = 20000,
        minable = { result = "kj_electric_laser" },
        rotation_speed = 0.005,
        turret_base_has_direction = true,
        prepare_range = 70,
        collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
        loot = data.raw.unit["maf-boss-biter-1"].loot,     
        attack_parameters = {
            cooldown = 500,
            projectile_creation_distance = 0,
            damage_modifier = 0.1,
            min_range = 0,
            range = 70,
            rotate_penalty = 0,
            turn_range = 1,
            ammo_type = {
                _base = data.raw["ammo"]["kj_laser_normal"].ammo_type,
                energy_consumption = "0MJ"
            }
        },
        resistances = {
            {
                type = "electric",
                percent = -500
            },
            {
                type = "explosion",
                percent = -50
            },
            {
                type = "laser",
                percent = 60
            },
            {
                type = "fire",
                percent = -15
            },       
            {
                type = "physical",
                percent = 20
            },
            {
                type = "poison",
                percent = 100
            }
        },
        fast_replaceable_group = "heavy-turret"        
    },
    {
        _base = data.raw["ammo-turret"]["kj_laser"],
        type = "electric-turret",
        name = "kj_electric_laser_player",
        energy_source = {
            type = "electric",
            buffer_capacity = "100MJ",
            usage_priority = "primary-input",
            input_flow_limit = "10MW",
            drain = "1MW"
        },
        max_health = 2500,
        minable = { result = "kj_electric_laser_player" },
        rotation_speed = 0.005,
        turret_base_has_direction = true,
        prepare_range = 40,
        collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
        resistances = {
            _replace = true
        },
        attack_parameters = {
            cooldown = 150,
            projectile_creation_distance = 0,
            damage_modifier = 0.2,
            min_range = 0,
            range = 40,
            rotate_penalty = 0,
            turn_range = 0.25,
            ammo_type = {
                _base = data.raw["ammo"]["kj_laser_normal"].ammo_type,
                energy_consumption = "10MJ"
            }
        },
        fast_replaceable_group = "heavy-turret"        
    }    
}

