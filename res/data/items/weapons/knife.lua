return {
    id = "weapon_knife",
    idDesc = "weapon_knife_desc",
    itemType = "Weapon",
    weight = 1.2,
    volume = 1.3,
    weaponType = "Melee",
    damage = 30,
    equippable = true,
    reloadable = false,
    sound = 'MELEE',
    mode = {
        {
            name = "Slash",
            cost = 3,
            accuracy = 85,
            attacks = 1,
            damageType = 'slashing'
        },
        {
            name = "Stab",
            cost = 3,
            accuracy = 85,
            attacks = 1,
            damageType = 'piercing'
        }
    }
}
