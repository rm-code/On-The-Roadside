return {
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
        { type = 'Miscellaneous', id = 'misc_glass_shard', tries = 6, chance = 20 }
    }
}
