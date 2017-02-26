return {
    {
        id         = "weapon_knife",
        idDesc     = "weapon_knife_desc",
        itemType   = "Weapon",
        weight     = 1.2,
        volume     = 1.3,
        equippable = true,
        stackable  = false,
        permanent  = false,
        subType    = "Melee",
        damage     = 18,
        reloadable = false,
        sound      = 'MELEE',
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
        },
        tags = {
            'humanoid'
        }
    },
    {
        id         = "weapon_tonfa",
        idDesc     = "weapon_tonfa_desc",
        itemType   = "Weapon",
        weight     = 1.2,
        volume     = 1.3,
        equippable = true,
        stackable  = false,
        permanent  = false,
        subType    = "Melee",
        damage     = 24,
        reloadable = false,
        sound      = 'MELEE',
        mode = {
            {
                name       = "Single",
                cost       = 7,
                accuracy   = 85,
                attacks    = 1,
                damageType = 'bludgeoning'
            }
        },
        tags = {
            'humanoid'
        }
    },
    {
        id         = "weapon_bite",
        idDesc     = "weapon_bite_desc",
        itemType   = "Weapon",
        weight     = 0.0,
        volume     = 0.0,
        equippable = true,
        stackable  = false,
        permanent  = true,
        subType    = "Melee",
        damage     = 14,
        reloadable = false,
        sound      = 'MELEE',
        mode = {
            {
                name = "Bite",
                cost = 8,
                accuracy = 90,
                attacks = 1,
                damageType = 'piercing'
            }
        },
        tags = {
            'creature'
        }
    }
}
