local Object = require( 'src.Object' );

local Weapon = {};

function Weapon.new( template )
    local self = Object.new():addInstance( 'Weapon' );

    local name = template.name;
    local damage = template.damage;
    local range  = template.range;
    local mode = 'single';

    function self:getAccuracy()
        return template.mode[mode].accuracy;
    end

    function self:getDamage()
        return damage;
    end

    function self:getFiringMode()
        return mode;
    end

    function self:getName()
        return name;
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

    return self;
end

return Weapon;
