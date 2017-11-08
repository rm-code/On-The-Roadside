return {
    {
        id         = "weapon_aks74",
        idDesc     = "weapon_aks74_desc",
        itemType   = "Weapon",
        weight     = 2.7,
        volume     = 3.0,
        equippable = true,
        stackable  = false,
        permanent  = false,
        caliber    = "5.45x39mm",
        sound      = 'ASSAULT_RIFLE',
        subType    = "Ranged",
        damage     = 26,
        rpm        = 650,
        magSize    = 30,
        reloadable = true,
        range      = 30,
        mode = {
            {
                name     = "Single",
                cost     = 12,
                accuracy = 80,
                attacks  = 1,
            },
            {
                name     = "Full-Auto",
                cost     = 25,
                accuracy = 40,
                attacks  = 5,
            }
        },
        tags = {
            'humanoid'
        }
    },
    {
        id         = "weapon_rpg7",
        idDesc     = "weapon_rpg7_desc",
        itemType   = "Weapon",
        weight     = 5.7,
        volume     = 9.0,
        equippable = true,
        stackable  = false,
        permanent  = false,
        subType    = "Ranged",
        caliber    = "OG-7V",
        sound      = 'ROCKET_LAUNCHER',
        damage     = 120,
        magSize    = 1,
        reloadable = true,
        range      = 30,
        mode = {
            {
                name = "Single",
                cost = 30,
                accuracy = 65,
                attacks = 1,
            }
        },
        tags = {
            'humanoid'
        }
    },
    {
        id         = "weapon_benelli_m4",
        idDesc     = "weapon_benelli_m4_desc",
        itemType   = "Weapon",
        weight     = 2.3,
        volume     = 4.5,
        equippable = true,
        stackable  = false,
        permanent  = false,
        subType    = "Ranged",
        caliber    = "12_gauge",
        sound      = 'SHOTGUN',
        damage     = 15,
        magSize    = 8,
        reloadable = true,
        range      = 15,
        mode = {
            {
                name = "Single",
                cost = 14,
                accuracy = 25,
                attacks = 1,
            }
        },
        tags = {
            'humanoid'
        }
    }
}
