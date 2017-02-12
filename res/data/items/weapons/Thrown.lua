return {
    {
        id       = "weapon_m67_grenade",
        idDesc = "weapon_m67_grenade_desc",
        itemType = "Weapon",
        weight   = 0.2,
        volume = 0.1,
        weaponType = "Thrown",
        damage   = 120,
        equippable = true,
        reloadable = false,
        stackable = true,
        range = 10,
        sound = 'MELEE',
        mode = {
            {
                name = "Throw",
                cost = 3,
            }
        },
        effects = {
            explosive = { blastRadius = 2 },
            customSprite = { sprite = 8 }
        }
    },
    {
        id       = "weapon_shuriken",
        idDesc = "weapon_shuriken_desc",
        itemType = "Weapon",
        weight   = 0.2,
        volume = 0.0,
        weaponType = "Thrown",
        damage   = 40,
        equippable = true,
        reloadable = false,
        stackable = true,
        range = 10,
        sound = 'MELEE',
        mode = {
            {
                name = "Throw",
                cost = 3,
                damageType = 'piercing'
            }
        },
        effects = {
            customSprite = { sprite = 16 }
        }
    }
}
