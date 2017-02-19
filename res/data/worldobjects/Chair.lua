return {
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
}
