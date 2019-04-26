---
-- cover:
--      => 0: No cover
--      => 1: Half cover
--      => 2: Full cover
--
return {
    {
        id = 'worldobject_chair',
        size = 15,
        cover = 1,
        hp = 10,
        interactionCost = {
            stand  = 5,
            crouch = 6,
            prone  = 7,
        },
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
        cover = 1,
        hp = 12,
        interactionCost = {
            stand  = 5,
            crouch = 6,
            prone  = 7,
        },
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
        cover = 1,
        hp = 12,
        interactionCost = {
            stand  = 5,
            crouch = 6,
            prone  = 7,
        },
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
        cover = 1,
        hp = 30,
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
        cover = 2,
        hp = 40,
        interactionCost = {
            stand  = 3,
            crouch = 3,
            prone  = 4,
        },
        destructible = true,
        openable = true,
        blocksVision = true,
        blocksPathfinding = false,
        group = "DOOR",
        drops = {
            { id = 'misc_nail', tries = 10, chance = 20 },
            { id = 'misc_splintered_wood', tries = 3, chance = 40 }
        }
    },
    {
        id = 'worldobject_fence',
        size = 35,
        cover = 1,
        hp = 14,
        interactionCost = {
            stand  = 5,
            crouch = 6,
            prone  = 7,
        },
        destructible = true,
        climbable = true,
        blocksVision = false,
        blocksPathfinding = false,
        group = "FENCE",
        connections = { "DOOR", "FENCE", "WALL" },
        drops = {
            { id = 'misc_nail', tries = 10, chance = 20 },
            { id = 'misc_splintered_wood', tries = 3, chance = 40 }
        }
    },
    {
        id = 'worldobject_fencegate',
        size = 40,
        cover = 1,
        hp = 15,
        interactionCost = {
            stand  = 3,
            crouch = 3,
            prone  = 4,
        },
        destructible = true,
        openable = true,
        blocksVision = false,
        blocksPathfinding = false,
        group = "FENCE",
        drops = {
            { id = 'misc_nail', tries = 10, chance = 20 },
            { id = 'misc_splintered_wood', tries = 3, chance = 40 }
        }
    },
    {
        id = 'worldobject_lowwall',
        size = 35,
        cover = 1,
        interactionCost = {
            stand  = 5,
            crouch = 6,
            prone  = 7,
        },
        destructible = false,
        climbable = true,
        blocksVision = true,
        blocksPathfinding = false,
        group = "WALL",
        connections = { "DOOR", "FENCE", "WALL" }
    },
    {
        id = 'worldobject_table',
        size = 25,
        cover = 1,
        hp = 20,
        interactionCost = {
            stand  = 5,
            crouch = 6,
            prone  = 7,
        },
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
        cover = 2,
        destructible = false,
        blocksVision = true,
        blocksPathfinding = true
    },
    {
        id = 'worldobject_wall',
        size = 100,
        cover = 2,
        destructible = false,
        blocksVision = true,
        blocksPathfinding = true,
        group = "WALL",
        connections = { "DOOR", "WALL", "WINDOW" }
    },
    {
        id = 'worldobject_window',
        size = 100,
        cover = 1,
        hp = 1,
        destructible = true,
        debrisID = 'worldobject_lowwall',
        blocksVision = false,
        blocksPathfinding = true,
        group = "WINDOW",
        drops = {
            { id = 'misc_glass_shard', tries = 6, chance = 20 }
        }
    }
}
