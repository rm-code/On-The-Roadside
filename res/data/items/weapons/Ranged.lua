return {
    {
        id         = "weapon_aks74",
        idDesc     = "weapon_aks74_desc",
        itemType   = "Weapon",
        weight     = 2.7,
        volume     = 3.0,
        equippable = true,
        permanent  = false,
        tags = {
            'humanoid'
        },
        subType    = "Ranged",
        sound      = 'sound_assault_rifle',
        damage     = 3,
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
        rounds = 30,
        rpm        = 650,
        damageType = 'piercing',
        effects = {
            customSpeed = { speed = 35 }
        }
    },
    {
        id         = "weapon_rpg7",
        idDesc     = "weapon_rpg7_desc",
        itemType   = "Weapon",
        weight     = 5.7,
        volume     = 9.0,
        equippable = true,
        permanent  = false,
        tags = {
            'humanoid'
        },
        subType    = "Ranged",
        sound      = 'sound_rocket_launcher',
        damage     = 8,
        reloadable = true,
        mode = {
            {
                name = "Single",
                cost = 30,
                accuracy = 65,
                attacks = 1,
            }
        },
        rounds = 1,
        damageType = 'explosive',
        areaOfEffectRadius = 5,
        effects = {
            explosive = { blastRadius = 5 },
            customSpeed = { speed = 12, increase = 1, final = 35 }
        }
    },
    {
        id         = "weapon_benelli_m4",
        idDesc     = "weapon_benelli_m4_desc",
        itemType   = "Weapon",
        weight     = 2.3,
        volume     = 4.5,
        equippable = true,
        permanent  = false,
        tags = {
            'humanoid'
        },
        subType    = "Ranged",
        sound      = 'sound_shotgun',
        damage     = 2,
        reloadable = true,
        mode = {
            {
                name = "Single",
                cost = 14,
                accuracy = 25,
                attacks = 1,
            }
        },
        rounds = 8,
        damageType = 'piercing',
        effects = {
            spreadsOnShot = { pellets = 6 },
            customSprite  = { sprite = "12_gauge" }
        }
    }
}
