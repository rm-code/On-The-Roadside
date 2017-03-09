return {
    id = 'human',
    bloodVolume = 5,
    defaultCarryWeight = 100,
    defaultCarryVolume = 10,
    tags = {
        whitelist = {
            'humanoid'
        },
        blacklist = {
            'creature'
        }
    },
    -- ################################## Head
    {
        id = 'head',
        type = 'entry',
        health = 30
    },
    {
        id = 'brain',
        type = 'node',
        health = 15,
        effects = {
            'death'
        }
    },
    {
        id = 'ears',
        type = 'node',
        health = 20
    },
    {
        id = 'eyes',
        type = 'node',
        health = 20,
        effects = {
            'blindness'
        }
    },
    {
        id = 'nose',
        type = 'node',
        health = 30
    },
    {
        id = 'skull',
        type = 'container',
        health = 30
    },
    {
        id = 'throat',
        type = 'node',
        health = 20,
        effects = {
            'death'
        }
    },
    -- ################################## Limbs
    {
        id = 'arm_left',
        type = 'entry',
        health = 50
    },
    {
        id = 'hand_left',
        type = 'entry',
        health = 40
    },
    {
        id = 'arm_right',
        type = 'entry',
        health = 50
    },
    {
        id = 'hand_right',
        type = 'entry',
        health = 40
    },
    {
        id = 'leg_left',
        type = 'entry',
        health = 50
    },
    {
        id = 'foot_right',
        type = 'entry',
        health = 40
    },
    {
        id = 'foot_left',
        type = 'entry',
        health = 40
    },
    {
        id = 'leg_right',
        type = 'entry',
        health = 50
    },
    -- ################################## Torso
    {
        id = 'torso',
        type = 'entry',
        health = 60
    },
    {
        id = 'heart',
        type = 'node',
        health = 30,
        effects = {
            'death'
        }
    },
    {
        id = 'kidneys',
        type = 'node',
        health = 40,
        effects = {
            'death'
        }
    },
    {
        id = 'liver',
        type = 'node',
        health = 30,
        effects = {
            'death'
        }
    },
    {
        id = 'lungs',
        type = 'node',
        health = 40,
        effects = {
            'death'
        }
    },
    {
        id = 'ribcage',
        type = 'container',
        health = 50
    },
    -- ################################## Equipment
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
