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
        tags = {
            'humanoid'
        },
        subType    = "Ranged",
        sound      = 'ASSAULT_RIFLE',
        damage     = 26,
        reloadable = true,
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
        caliber    = "5.45x39mm",
        magSize    = 30,
        range      = 30,
        rpm        = 650
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
        tags = {
            'humanoid'
        },
        subType    = "Ranged",
        sound      = 'ROCKET_LAUNCHER',
        damage     = 120,
        reloadable = true,
        mode = {
            {
                name = "Single",
                cost = 30,
                accuracy = 65,
                attacks = 1,
            }
        },
        caliber    = "OG-7V",
        magSize    = 1,
        range      = 30
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
        tags = {
            'humanoid'
        },
        subType    = "Ranged",
        sound      = 'SHOTGUN',
        damage     = 15,
        reloadable = true,
        mode = {
            {
                name = "Single",
                cost = 14,
                accuracy = 25,
                attacks = 1,
            }
        },
        caliber    = "12_gauge",
        magSize    = 8,
        range      = 15
    }
}
