return {
    {
        id         = "weapon_m67_grenade",
        idDesc     = "weapon_m67_grenade_desc",
        itemType   = "Weapon",
        weight     = 0.2,
        volume     = 0.1,
        equippable = true,
        stackable  = true,
        weaponType = "Thrown",
        damage     = 120,
        reloadable = false,
        range      = 10,
        sound      = 'MELEE',
        mode = {
            {
                name = "Throw",
                cost = 3,
            }
        },
        effects = {
            explosive    = { blastRadius = 2 },
            customSprite = { sprite = 8 }
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
        weaponType = "Thrown",
        damage     = 40,
        reloadable = false,
        range      = 10,
        sound      = 'MELEE',
        mode = {
            {
                name       = "Throw",
                cost       = 3,
                damageType = 'piercing'
            }
        },
        effects = {
            customSprite = { sprite = 16 }
        }
    }
}
