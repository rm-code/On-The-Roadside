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

    local damage = template.damage;
    local range = template.range;
    local ammoType = template.ammoType;
    local modeIndex = 1;
    local mode = template.mode[modeIndex];
    local firingDelay = 1 / ( template.rpm / 60 );
    local magSize = template.magSize;
    local magazine;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:reload( newMag )
        assert( ammoType == newMag:getAmmoType(), 'Ammunition Type doesn\'t match the gun!' );
        magazine = newMag;
    end

    function self:shoot()
        magazine:removeShell();
    end

    function self:selectNextFiringMode()
        modeIndex = modeIndex + 1 > #template.mode and 1 or modeIndex + 1;
        mode = template.mode[modeIndex];
    end

    function self:selectPrevFiringMode()
        modeIndex = modeIndex - 1 < 1 and #template.mode or modeIndex - 1;
        mode = template.mode[modeIndex];
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getAccuracy()
        return mode.accuracy;
    end

    function self:getAmmoType()
        return ammoType;
    end

    function self:getAttackCost()
        return mode.cost;
    end

    function self:getDamage()
        return damage;
    end

    function self:getFiringDelay()
        return firingDelay;
    end

    function self:getFiringMode()
        return mode;
    end

    function self:getMagazine()
        return magazine;
    end

    function self:getMagSize()
        return magSize;
    end

    function self:getRange()
        return range;
    end

    function self:getShots()
        return mode.shots;
    end

    return self;
end

return Weapon;
