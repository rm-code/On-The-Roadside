return {
    id = 'worldobject_door',
    sprite = 44,
    openSprite = 96,
    color = { 102, 57, 49 },
    size = 95,
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
        { type = 'Miscellaneous', id = 'misc_nail', tries = 10, chance = 20 },
        { type = 'Miscellaneous', id = 'misc_splintered_wood', tries = 3, chance = 40 }
    }
}
