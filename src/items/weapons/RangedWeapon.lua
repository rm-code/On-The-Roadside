local Weapon = require( 'src.items.weapons.Weapon' );
local Magazine = require( 'src.items.weapons.Magazine' );

local RangedWeapon = {};

function RangedWeapon.new( template )
    local self = Weapon.new( template ):addInstance( 'RangedWeapon' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local rpm = template.rpm or 60;
    local firingDelay = 1 / ( rpm / 60 );
    local magazine = Magazine( template.caliber, template.magSize )
    local range = template.range;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

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

    function self:getFiringDelay()
        return firingDelay;
    end

    function self:getMagazine()
        return magazine;
    end

    function self:getRange()
        return range;
    end

    return self;
end

return RangedWeapon;
