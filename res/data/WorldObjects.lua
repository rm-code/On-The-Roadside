return {
    {
        id = 'worldobject_chair',
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
        id = 'worldobject_toilet',
        size = 15,
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
            { id = 'misc_ceramic_shard', tries = 10, chance = 20 }
        }
    },
    {
        id = 'worldobject_shower',
        size = 15,
        hp = 35,
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
            { id = 'misc_ceramic_shard', tries = 10, chance = 20 }
        }
    },
    {
        id = 'worldobject_crate',
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
        size = 100,
        destructible = false,
        blocksVision = true,
        blocksPathfinding = true
    },
    {
        id = 'worldobject_wall',
        size = 100,
        destructible = false,
        blocksVision = true,
        blocksPathfinding = true
    },
    {
        id = 'worldobject_window',
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
