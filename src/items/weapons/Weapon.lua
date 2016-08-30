local Item = require( 'src.items.Item' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Weapon = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Weapon.new( template )
    local self = Item.new( template.name, template.itemType ):addInstance( 'Weapon' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local weaponType = template.weaponType;
    local damage = template.damage;
    local modeIndex = 1;
    local mode = template.mode[modeIndex];

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:selectNextFiringMode()
        modeIndex = modeIndex + 1 > #template.mode and 1 or modeIndex + 1;
        mode = template.mode[modeIndex];
    end

    function self:selectPrevFiringMode()
        modeIndex = modeIndex - 1 < 1 and #template.mode or modeIndex - 1;
        mode = template.mode[modeIndex];
    end

    function self:serialize()
        local t = {
            ['name'] = template.name,
            ['itemType'] = template.itemType,
            ['modeIndex'] = modeIndex
        };
        return t;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getAccuracy()
        return mode.accuracy;
    end

    function self:getAttackCost()
        return mode.cost;
    end

    function self:getDamage()
        return damage;
    end

    function self:getAttackMode()
        return mode;
    end

    function self:getAttacks()
        return mode.attacks;
    end

    function self:getWeaponType()
        return weaponType;
    end

    function self:getAttackModeIndex()
        return modeIndex;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setAttackMode( nmodeIndex )
        modeIndex = nmodeIndex;
        mode = template.mode[modeIndex];
    end

    return self;
end

return Weapon;
