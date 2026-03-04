return {
    {
        type = "capsule",
        name = "emergency-return",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/emergency_recall.png",
        subgroup = "capsule",
        order = "a[items]-b[emergency-return]",
        stack_size = 10,
        capsule_action = {
            type = "use-on-self",
            attack_parameters = {
                type = "projectile",
                activation_type = "consume",
                ammo_category = "capsule",
                cooldown = 600,
                range = 0,
                ammo_type = {
                    category = "capsule",
                    target_type = "position",
                    action = {
                        type = "direct",
                        action_delivery = {
                            type = "instant"
                        }
                    }
                }
            }
        }
    }
}

