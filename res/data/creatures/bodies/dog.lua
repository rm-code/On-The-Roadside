return {
    id = 'dog',
    defaultCarryWeight = 20,
    defaultCarryVolume = 5,
    hp = 4,
    size = {
        stand  = 50,
        crouch = 30,
        prone  = 20
    },
    tags = {
        whitelist = {
            'creature'
        },
        blacklist = {
            'humanoid'
        }
    },
    bodyparts = {
        {
            name = 'head',
            damageModifier = 2.0,
            equipment = 'equip_torso',
            effects = {
                'blind'
            }
        },
        {
            name = 'torso',
            damageModifier = 1.0,
            equipment = 'equip_torso'
        },
        {
            name = 'legs',
            damageModifier = 1.0,
            equipment = 'equip_legs'
        }
    },
    equipment = {
        {
            id = 'equip_mouth',
            type = 'equipment',
            itemType = 'Weapon',
            subType = 'Melee',
            sort = 1
        },
        {
            id = 'equip_torso',
            type = 'equipment',
            itemType = 'Armor',
            subType = 'Fur',
            sort = 2
        },
        {
            id = 'equip_legs',
            type = 'equipment',
            itemType = 'Armor',
            subType = 'Fur',
            sort = 3
        }
    }
}
