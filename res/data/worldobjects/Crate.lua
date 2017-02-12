return {
    id = 'worldobject_crate',
    sprite = 247,
    color = { 143, 86, 59 },
    size = 70,
    hp = 110,
    energyReduction = 50,
    destructible = true,
    blocksVision = false,
    blocksPathfinding = true,
    container = true,
    drops = {
        { type = 'Miscellaneous', id = 'misc_nail', tries = 10, chance = 20 },
        { type = 'Miscellaneous', id = 'misc_splintered_wood', tries = 3, chance = 40 }
    }
}
