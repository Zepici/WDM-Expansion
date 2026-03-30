return {
    {
        type = "capsule",
        name = "emergency-return",
        icon = "__Warp-Drive-Machine-Expansion__/graphics/icon/emergency_recall.png",
        subgroup = "capsule",
        order = "a[items]-b[emergency-return]",
        stack_size = 10,
        custom_tooltip_fields = {
            {
                name = {"item-description.wdm-emergency-return-loss-label"},
                value = {"item-description.wdm-emergency-return-loss-50"},
                quality_values = {
                    normal = {"item-description.wdm-emergency-return-loss-50"},
                    uncommon = {"item-description.wdm-emergency-return-loss-45"},
                    rare = {"item-description.wdm-emergency-return-loss-40"},
                    epic = {"item-description.wdm-emergency-return-loss-35"},
                    legendary = {"item-description.wdm-emergency-return-loss-25"}
                }
            }
        },
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

