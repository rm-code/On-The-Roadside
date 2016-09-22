local Weapon = require( 'src.items.weapons.Weapon' );

local RangedWeapon = {};

function RangedWeapon.new( template )
    local self = Weapon.new( template ):addInstance( 'RangedWeapon' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local rpm = template.rpm or 60;
    local firingDelay = 1 / ( rpm / 60 );
    local caliber = template.caliber;
    local magSize = template.magSize;
    local magazine;
    local range = template.range;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:reload( newMag )
        assert( caliber == newMag:getCaliber(), 'Ammunition Type doesn\'t match the gun!' );
        magazine = newMag;
    end

    function self:attack()
        magazine:removeShell();
    end

    function self:serialize()
        local t = {
            ['id'] = template.id,
            ['itemType'] = template.itemType,
            ['modeIndex'] = self:getAttackModeIndex()
        };

        if magazine then
            t['magazine'] = magazine:serialize()
        end

        return t;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getCaliber()
        return caliber;
    end

    function self:getFiringDelay()
        return firingDelay;
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

    return self;
end

return RangedWeapon;
