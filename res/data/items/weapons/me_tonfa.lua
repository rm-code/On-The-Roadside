return {
    id         = "weapon_tonfa",
    idDesc = "weapon_tonfa_desc",
    itemType   = "Weapon",
    weight     = 1.2,
    volume = 1.3,
    weaponType = "Melee",
    damage     = 30,
    equippable = true,
    reloadable = false,
    sound = 'MELEE',
    mode = {
        {
            name = "Single",
            cost = 3,
            accuracy = 85,
            attacks = 1,
            damageType = 'bludgeoning'
        }
    }
}
