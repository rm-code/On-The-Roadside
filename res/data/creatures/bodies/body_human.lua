return {
    id = 'body_human',
    defaultCarryWeight = 100,
    defaultCarryVolume = 10,
    size = {
        stand  = 80,
        crouch = 50,
        prone  = 30
    },
    tags = {
        whitelist = {
            'humanoid'
        },
        blacklist = {
            'creature'
        }
    },
    bodyparts = {
        {
            name = 'bodypart_head',
            damageModifier = 2.0,
            equipment = 'equip_head',
            effects = {
                'blind'
            }
        },
        {
            name = 'bodypart_torso',
            damageModifier = 1.0,
            equipment = 'equip_torso'
        },
        {
            name = 'bodypart_hands',
            damageModifier = 1.0,
            equipment = 'equip_hands'
        },
        {
            name = 'bodypart_legs',
            damageModifier = 1.0,
            equipment = 'equip_legs'
        },
        {
            name = 'bodypart_feet',
            damageModifier = 1.0,
            equipment = 'equip_feet'
        }
    },
    equipment = {
        {
            id = 'equip_head',
            type = 'equipment',
            itemType = 'Armor',
            subType = 'Headgear',
            sort = 1
        },
        {
            id = 'equip_backpack',
            type = 'equipment',
            itemType = 'Container',
            sort = 2
        },
        {
            id = 'equip_torso',
            type = 'equipment',
            itemType = 'Armor',
            subType = 'Jacket',
            sort = 3
        },
        {
            id = 'equip_hands',
            type = 'equipment',
            itemType = 'Weapon',
            sort = 4
        },
        {
            id = 'equip_legs',
            type = 'equipment',
            itemType = 'Armor',
            subType = 'Trousers',
            sort = 5
        },
        {
            id = 'equip_feet',
            type = 'equipment',
            itemType = 'Armor',
            subType = 'Footwear',
            sort = 6
        }
    }
}
