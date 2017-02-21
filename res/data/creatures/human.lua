return {
    id = 'human',
    bloodVolume = 5,
    defaultCarryWeight = 100,
    defaultCarryVolume = 10,
    -- ################################## Head
    {
        id = 'head',
        type = 'entry',
        health = 120
    },
    {
        id = 'brain',
        type = 'node',
        health = 30,
        effects = {
            'death'
        }
    },
    {
        id = 'ears',
        type = 'node',
        health = 40
    },
    {
        id = 'eyes',
        type = 'node',
        health = 30,
        effects = {
            'blindness'
        }
    },
    {
        id = 'nose',
        type = 'node',
        health = 40
    },
    {
        id = 'skull',
        type = 'container',
        health = 80
    },
    {
        id = 'throat',
        type = 'node',
        health = 50,
        effects = {
            'death'
        }
    },
    -- ################################## Limbs
    {
        id = 'arm_left',
        type = 'entry',
        health = 120
    },
    {
        id = 'hand_left',
        type = 'entry',
        health = 80
    },
    {
        id = 'arm_right',
        type = 'entry',
        health = 120
    },
    {
        id = 'hand_right',
        type = 'entry',
        health = 80
    },
    {
        id = 'leg_left',
        type = 'entry',
        health = 120
    },
    {
        id = 'foot_right',
        type = 'entry',
        health = 100
    },
    {
        id = 'foot_left',
        type = 'entry',
        health = 100
    },
    {
        id = 'leg_right',
        type = 'entry',
        health = 120
    },
    -- ################################## Torso
    {
        id = 'torso',
        type = 'entry',
        health = 300
    },
    {
        id = 'heart',
        type = 'node',
        health = 50,
        effects = {
            'death'
        }
    },
    {
        id = 'kidneys',
        type = 'node',
        health = 60,
        effects = {
            'death'
        }
    },
    {
        id = 'liver',
        type = 'node',
        health = 50,
        effects = {
            'death'
        }
    },
    {
        id = 'lungs',
        type = 'node',
        health = 80,
        effects = {
            'death'
        }
    },
    {
        id = 'ribcage',
        type = 'container',
        health = 220
    },
    -- ################################## Equipment
    {
        id = 'equip_head',
        type = 'equipment',
        itemType = 'Clothing',
        subType = 'Headgear',
        sort = 1
    },
    {
        id = 'equip_backpack',
        type = 'equipment',
        itemType = 'Bag',
        sort = 2
    },
    {
        id = 'equip_torso',
        type = 'equipment',
        itemType = 'Clothing',
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
        itemType = 'Clothing',
        subType = 'Trousers',
        sort = 5
    },
    {
        id = 'equip_feet',
        type = 'equipment',
        itemType = 'Clothing',
        subType = 'Footwear',
        sort = 6
    }
}
