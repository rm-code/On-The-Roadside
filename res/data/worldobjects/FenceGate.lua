return {
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
}
