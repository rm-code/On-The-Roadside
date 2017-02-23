return {
    {
        id         = "weapon_knife",
        idDesc     = "weapon_knife_desc",
        itemType   = "Weapon",
        weight     = 1.2,
        volume     = 1.3,
        equippable = true,
        stackable  = false,
        subType    = "Melee",
        damage     = 30,
        reloadable = false,
        sound      = 'MELEE',
        mode = {
            {
                name       = "Slash",
                cost       = 3,
                accuracy   = 85,
                attacks    = 1,
                damageType = 'slashing'
            },
            {
                name       = "Stab",
                cost       = 3,
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
        subType    = "Melee",
        damage     = 30,
        reloadable = false,
        sound      = 'MELEE',
        mode = {
            {
                name       = "Single",
                cost       = 3,
                accuracy   = 85,
                attacks    = 1,
                damageType = 'bludgeoning'
            }
        },
        tags = {
            'humanoid'
        }
    }
}
