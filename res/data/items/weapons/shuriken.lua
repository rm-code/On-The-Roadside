return {
    id       = "weapon_shuriken",
    itemType = "Weapon",
    weight   = 0.2,
    volume = 0.0,
    weaponType = "Thrown",
    damage   = 40,
    equippable = true,
    reloadable = false,
    range = 10,
    sound = 'MELEE',
    mode = {
        {
            name = "Throw",
            cost = 3,
        }
    },
    effects = {
        customSprite = { sprite = 16 }
    }
}
