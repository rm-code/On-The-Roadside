return {
    id       = "weapon_m67_grenade",
    itemType = "Weapon",
    weight   = 0.2,
    volume = 0.1,
    weaponType = "Thrown",
    damage   = 120,
    equippable = true,
    reloadable = false,
    range = 10,
    mode = {
        {
            name = "Throw",
            cost = 3,
        }
    },
    effects = {
        explosive = { blastRadius = 2 },
        customSprite = { sprite = 8 }
    }
}
