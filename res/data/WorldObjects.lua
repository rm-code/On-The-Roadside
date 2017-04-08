return {
    {
        id = 'worldobject_chair',
        sprite = 111,
        color = { 143, 86, 59 },
        size = 15,
        hp = 45,
        interactionCost = {
            stand  = 5,
            crouch = 6,
            prone  = 7,
        },
        energyReduction = 30,
        destructible = true,
        climbable = true,
        blocksVision = false,
        drops = {
            { id = 'misc_nail', tries = 10, chance = 20 },
            { id = 'misc_splintered_wood', tries = 3, chance = 40 }
        }
    },
    {
        id = 'worldobject_crate',
        sprite = 247,
        color = { 143, 86, 59 },
        size = 50,
        hp = 110,
        energyReduction = 50,
        destructible = true,
        blocksVision = true,
        blocksPathfinding = true,
        container = true,
        drops = {
            { id = 'misc_nail', tries = 10, chance = 20 },
            { id = 'misc_splintered_wood', tries = 3, chance = 40 }
        }
    },
    {
        id = 'worldobject_door',
        sprite = 44,
        openSprite = 96,
        color = { 102, 57, 49 },
        size = 100,
        hp = 110,
        interactionCost = {
            stand  = 3,
            crouch = 3,
            prone  = 4,
        },
        energyReduction = 40,
        destructible = true,
        openable = true,
        blocksVision = true,
        blocksPathfinding = false,
        drops = {
            { id = 'misc_nail', tries = 10, chance = 20 },
            { id = 'misc_splintered_wood', tries = 3, chance = 40 }
        }
    },
    {
        id = 'worldobject_fence',
        sprite = 62,
        color = { 143, 86, 59 },
        size = 35,
        hp = 55,
        interactionCost = {
            stand  = 5,
            crouch = 6,
            prone  = 7,
        },
        energyReduction = 30,
        destructible = true,
        climbable = true,
        blocksVision = false,
        blocksPathfinding = false,
        drops = {
            { id = 'misc_nail', tries = 10, chance = 20 },
            { id = 'misc_splintered_wood', tries = 3, chance = 40 }
        }
    },
    {
        id = 'worldobject_fencegate',
        sprite = 241,
        openSprite = 96,
        color = { 143, 86, 59 },
        size = 40,
        hp = 65,
        interactionCost = {
            stand  = 3,
            crouch = 3,
            prone  = 4,
        },
        energyReduction = 40,
        destructible = true,
        openable = true,
        blocksVision = false,
        blocksPathfinding = false,
        drops = {
            { id = 'misc_nail', tries = 10, chance = 20 },
            { id = 'misc_splintered_wood', tries = 3, chance = 40 }
        }
    },
    {
        id = 'worldobject_lowwall',
        sprite = 62,
        color = { 132, 126, 135 },
        size = 35,
        interactionCost = {
            stand  = 5,
            crouch = 6,
            prone  = 7,
        },
        destructible = false,
        climbable = true,
        blocksVision = true,
        blocksPathfinding = false
    },
    {
        id = 'worldobject_table',
        sprite = 211,
        color = { 143, 86, 59 },
        size = 25,
        hp = 65,
        interactionCost = {
            stand  = 5,
            crouch = 6,
            prone  = 7,
        },
        energyReduction = 30,
        destructible = true,
        climbable = true,
        blocksVision = false,
        drops = {
            { id = 'misc_nail', tries = 10, chance = 20 },
            { id = 'misc_splintered_wood', tries = 3, chance = 40 }
        }
    },
    {
        id = 'worldobject_tree',
        sprite = 7,
        color = { 75, 105, 47 },
        size = 100,
        destructible = false,
        blocksVision = true,
        blocksPathfinding = true
    },
    {
        id = 'worldobject_wall',
        sprite = 36,
        color = { 132, 126, 135 },
        size = 100,
        destructible = false,
        blocksVision = true,
        blocksPathfinding = true
    },
    {
        id = 'worldobject_window',
        sprite = 177,
        color = { 95, 205, 228 },
        size = 100,
        hp = 25,
        energyReduction = 10,
        destructible = true,
        debrisID = 'worldobject_lowwall',
        blocksVision = false,
        blocksPathfinding = true,
        drops = {
            { id = 'misc_glass_shard', tries = 6, chance = 20 }
        }
    }
}
