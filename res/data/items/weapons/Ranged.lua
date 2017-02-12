return {
    {
        id         = "weapon_aks74",
        idDesc     = "weapon_aks74_desc",
        itemType   = "Weapon",
        weaponType = "Ranged",
        caliber    = "5.45x39mm",
        sound      = 'ASSAULT_RIFLE',
        weight     = 2.7,
        volume     = 3.0,
        damage     = 40,
        rpm        = 650,
        magSize    = 30,
        equippable = true,
        reloadable = true,
        range      = 30,
        mode = {
            {
                name = "Single",
                cost = 3,
                accuracy = 80,
                attacks = 1,
            },
            {
                name = "Full-Auto",
                cost = 10,
                accuracy = 50,
                attacks = 11,
            }
        }
    },
    {
        id         = "weapon_rpg7",
        idDesc     = "weapon_rpg7_desc",
        itemType   = "Weapon",
        weaponType = "Ranged",
        caliber    = "OG-7V",
        sound      = 'ROCKET_LAUNCHER',
        weight     = 5.7,
        volume     = 9.0,
        damage     = 0,
        magSize    = 1,
        equippable = true,
        reloadable = true,
        range      = 30,
        mode = {
            {
                name = "Single",
                cost = 10,
                accuracy = 65,
                attacks = 1,
            }
        }
    },
    {
        id         = "weapon_benelli_m4",
        idDesc     = "weapon_benelli_m4_desc",
        itemType   = "Weapon",
        weaponType = "Ranged",
        caliber    = "12 gauge",
        sound      = 'SHOTGUN',
        weight     = 2.3,
        volume     = 4.5,
        damage     = 20,
        magSize    = 8,
        equippable = true,
        reloadable = true,
        range      = 15,
        mode = {
            {
                name = "Single",
                cost = 3,
                accuracy = 25,
                attacks = 1,
            }
        }
    }
}
