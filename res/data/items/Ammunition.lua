return {
    {
        id         = "5.45x39mm",
        idDesc     = "5.45x39mm_desc",
        itemType   = "Ammunition",
        weight     = 0,
        volume     = 0,
        equippable = false,
        permanent  = false,
        tags = {
            'humanoid'
        },
        damageType = 'piercing',
        effects = {
            customSpeed = { speed = 35 }
        }
    },
    {
        id         = "12_gauge",
        idDesc     = "12_gauge_desc",
        itemType   = "Ammunition",
        weight     = 0,
        volume     = 0,
        equippable = false,
        permanent  = false,
        tags = {
            'humanoid'
        },
        damageType = 'piercing',
        effects = {
            spreadsOnShot = { pellets = 6 },
            customSprite  = { sprite = "12_gauge" }
        }
    },
    {
        id         = "OG-7V",
        idDesc     = "OG-7V_desc",
        itemType   = "Ammunition",
        weight     = 2.0,
        volume     = 2.0,
        equippable = false,
        permanent  = false,
        tags = {
            'humanoid'
        },
        damageType = 'explosive',
        effects = {
            explosive = { blastRadius = 5 },
            customSpeed = { speed = 12, increase = 1, final = 35 }
        }
    }
}
