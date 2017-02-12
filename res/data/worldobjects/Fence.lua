return {
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
        { type = 'Miscellaneous', id = 'misc_nail', tries = 10, chance = 20 },
        { type = 'Miscellaneous', id = 'misc_splintered_wood', tries = 3, chance = 40 }
    }
}
