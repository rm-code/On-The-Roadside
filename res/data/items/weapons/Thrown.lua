return {
    {
        id         = "weapon_m67_grenade",
        idDesc     = "weapon_m67_grenade_desc",
        itemType   = "Weapon",
        weight     = 0.2,
        volume     = 0.1,
        equippable = true,
        stackable  = true,
        permanent  = false,
        tags = {
            'humanoid'
        },
        subType    = "Thrown",
        damage     = 5,
        reloadable = false,
        sound      = 'sound_thrown',
        mode = {
            {
                name       = "Throw",
                cost       = 10,
                attacks    = 1,
                damageType = 'explosive'
            }
        },
        range = 10,
        effects = {
            explosive    = { blastRadius = 2 },
            customSprite = { sprite = "weapon_m67_grenade" }
        }
    },
    {
        id         = "weapon_shuriken",
        idDesc     = "weapon_shuriken_desc",
        itemType   = "Weapon",
        weight     = 0.2,
        volume     = 0.0,
        equippable = true,
        stackable  = true,
        permanent  = false,
        tags = {
            'humanoid'
        },
        subType    = "Thrown",
        damage     = 3,
        reloadable = false,
        sound      = 'sound_thrown',
        mode = {
            {
                name       = "Throw",
                cost       = 8,
                attacks    = 1,
                damageType = 'piercing'
            }
        },
        range = 10,
        effects = {
            customSprite = { sprite = "weapon_shuriken" }
        }
    }
}
