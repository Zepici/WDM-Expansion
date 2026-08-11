return {
    {
        type = "gun",
        name = "wdm-overpower-tesla-gun",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/overpower-teslagun.png",
        icon_size = 64,
        subgroup = "gun",
        order = "a[basic-clips]-h[wdm-overpower-tesla-gun]",
        stack_size = 5,
        hidden_in_factoriopedia = true,
        attack_parameters =
        {
            type = "beam",
            ammo_category = "overpower-tesla-gun",
            cooldown = 60,
            movement_slow_down_factor = 1,
            source_offset = {0.1, -0.75},
            source_direction_count = 8,
            range = 35,
            damage_modifier = 1
        }
    },
    {
        type = "ammo",
        name = "wdm-overpower-tesla-ammo",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/overpower-tesla-ammo2.png",
        icon_size = 64,
        subgroup = "ammo",
        order = "e[railgun-ammo]-a[wdm-overpower-tesla-ammo]",
        stack_size = 10,
        magazine_size = 1,
        hidden_in_factoriopedia = true,
        ammo_category = "overpower-tesla-gun",
        ammo_type =
        {
            target_type = "entity",
            action =
            {
                type = "direct",
                action_delivery =
                {
                    type = "instant",
                    target_effects =
                    {
                        {
                            type = "nested-result",
                            action =
                            {
                                type = "direct",
                                action_delivery =
                                {
                                    type = "chain",
                                    chain = "wdm-overpower-tesla-gun-chain",
                                }
                            }
                        },
                        {
                            type = "nested-result",
                            action =
                            {
                                type = "direct",
                                action_delivery =
                                {
                                    type = "beam",
                                    beam = "wdm-overpower-tesla-gun-beam-start",
                                    source_offset = {0, -1.31439},
                                    max_length = 80,
                                    duration = 30,
                                    add_to_shooter = false,
                                    destroy_with_source_or_target = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}