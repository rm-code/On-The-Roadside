return {
    id = 'dog',
    bloodVolume = 3,
    defaultCarryWeight = 20,
    defaultCarryVolume = 5,
    tags = {
        whitelist = {
            'creature'
        },
        blacklist = {
            'humanoid'
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
        health = 10,
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
        id = 'muzzle',
        type = 'node',
        health = 30
    },
    {
        id = 'skull',
        type = 'container',
        health = 40
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
        id = 'legs',
        type = 'entry',
        health = 40
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
        health = 20,
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
    -- ################################## Equipment
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
