return {
    id       = "weapon_enfield_l85a1",
    itemType = "Weapon",
    weight   = 3.1,
    weaponType = "Assault Rifle",
    damage   = 45,
    rpm      = 610,
    caliber  = "5.56x45mm",
    magSize  = 30,
    equippable = true,
    range = 30,
    mode = {
        {
            name = "Single",
            cost = 3,
            accuracy = 75,
            attacks = 1,
        },
        {
            name = "Full-Auto",
            cost = 10,
            accuracy = 60,
            attacks = 10,
        }
    }
}
