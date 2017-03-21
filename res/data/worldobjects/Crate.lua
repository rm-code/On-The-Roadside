return {
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
}
