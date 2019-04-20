return {
    {
        id         = "weapon_knife",
        idDesc     = "weapon_knife_desc",
        itemType   = "Weapon",
        weight     = 1.2,
        volume     = 1.3,
        equippable = true,
        permanent  = false,
        tags = {
            'humanoid'
        },
        subType    = "Melee",
        damage     = 5,
        reloadable = false,
        sound      = 'sound_melee',
        mode = {
            {
                name       = "Slash",
                cost       = 8,
                accuracy   = 85,
                attacks    = 1,
                damageType = 'slashing'
            },
            {
                name       = "Stab",
                cost       = 8,
                accuracy   = 85,
                attacks    = 1,
                damageType = 'piercing'
            }
        }
    },
    {
        id         = "weapon_tonfa",
        idDesc     = "weapon_tonfa_desc",
        itemType   = "Weapon",
        weight     = 1.2,
        volume     = 1.3,
        equippable = true,
        permanent  = false,
        tags = {
            'humanoid'
        },
        subType    = "Melee",
        damage     = 4,
        reloadable = false,
        sound      = 'sound_melee',
        mode = {
            {
                name       = "Single",
                cost       = 7,
                accuracy   = 85,
                attacks    = 1,
                damageType = 'bludgeoning'
            }
        }
    },
    {
        id         = "weapon_bite",
        idDesc     = "weapon_bite_desc",
        itemType   = "Weapon",
        weight     = 0.0,
        volume     = 0.0,
        equippable = true,
        permanent  = true,
        tags = {
            'creature'
        },
        subType    = "Melee",
        damage     = 2,
        reloadable = false,
        sound      = 'sound_melee',
        mode = {
            {
                name = "Bite",
                cost = 8,
                accuracy = 90,
                attacks = 1,
                damageType = 'piercing'
            }
        }
    }
}
