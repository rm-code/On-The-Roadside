return {
    id       = "weapon_fnp90",
    itemType = "Weapon",
    weaponType = "Submachine Gun",
    weight   = 2.1,
    damage   = 38,
    rpm      = 900,
    caliber  = "5.7x28mm",
    magSize  = 50,
    equippable = true,
    range = 25,
    mode = {
        {
            name = "Single",
            cost = 3,
            accuracy = 65,
            attacks = 1,
        },
        {
            name = "Full-Auto",
            cost = 8,
            accuracy = 40,
            attacks = 13,
        }
    }
}
