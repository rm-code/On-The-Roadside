return {
    {
        id         = "5.45x39mm",
        idDesc     = "5.45x39mm_desc",
        itemType   = "Ammunition",
        weight     = 0,
        volume     = 0,
        equippable = false,
        stackable  = true,
        damageType = 'piercing',
        effects = {
            customSpeed = { speed = 35 }
        },
        tags = {
            'humanoid'
        }
    },
    {
        id         = "12 gauge",
        idDesc     = "12 gauge_desc",
        itemType   = "Ammunition",
        weight     = 0,
        volume     = 0,
        equippable = false,
        stackable  = true,
        damageType = 'piercing',
        effects = {
            spreadsOnShot = { pellets = 12 }
        },
        tags = {
            'humanoid'
        }
    },
    {
        id         = "OG-7V",
        idDesc     = "OG-7V_desc",
        itemType   = "Ammunition",
        weight     = 2.0,
        volume     = 2.0,
        equippable = false,
        stackable  = true,
        effects = {
            explosive = { blastRadius = 5 },
            customSpeed = { speed = 12, increase = 1, final = 35 }
        },
        tags = {
            'humanoid'
        }
    }
}
