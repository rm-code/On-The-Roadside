return {
    id       = "weapon_aks74",
    itemType = "Weapon",
    weight   = 2.7,
    weaponType = "Ranged",
    damage   = 40,
    rpm      = 650,
    caliber  = "5.45x39mm",
    magSize  = 30,
    equippable = true,
    reloadable = true,
    range = 30,
    mode = {
        {
            name = "Single",
            cost = 3,
            accuracy = 80,
            attacks = 1,
        },
        {
            name = "Full-Auto",
            cost = 10,
            accuracy = 50,
            attacks = 11,
        }
    }
}
