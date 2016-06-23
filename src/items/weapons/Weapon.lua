local Item = require( 'src.items.Item' );

local Weapon = {};

function Weapon.new( template )
    local self = Item.new( template.name, template.itemType ):addInstance( 'Weapon' );

    local damage = template.damage;
    local range  = template.range;
    local ammoType = template.ammoType;
    local mode = 1;
    local firingDelay = 1 / ( template.rpm / 60 );
    local magazine;

    function self:reload( newMag )
        assert( ammoType == newMag:getAmmoType(), 'Ammunition Type doesn\'t match the gun!' );
        magazine = newMag;
    end

    function self:shoot()
        magazine:removeShell();
    end

    function self:getAccuracy()
        return template.mode[mode].accuracy;
    end

    function self:getAmmoType()
        return ammoType;
    end

    function self:getDamage()
        return damage;
    end

    function self:getFiringMode()
        return template.mode[mode];
    end

    function self:getRange()
        return range;
    end

    function self:getAttackCost()
        return template.mode[mode].cost;
    end

    function self:getShots()
        return template.mode[mode].shots;
    end

    function self:selectNextFiringMode()
        mode = mode + 1 > #template.mode and 1 or mode + 1;
    end

    function self:selectPrevFiringMode()
        mode = mode - 1 < 1 and #template.mode or mode - 1;
    end

    function self:getMagazine()
        return magazine;
    end

    function self:getFiringDelay()
        return firingDelay;
    end

    return self;
end

return Weapon;
