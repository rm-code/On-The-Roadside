local Object = require( 'src.Object' );

local Weapon = {};

function Weapon.new( template )
    local self = Object.new():addInstance( 'Weapon' );

    local name = template.name;
    local damage = template.damage;
    local range  = template.range;
    local attackCost = template.cost;
    local accuracy = template.accuracy;

    function self:getAccuracy()
        return accuracy;
    end

    function self:getDamage()
        return damage;
    end

    function self:getName()
        return name;
    end

    function self:getRange()
        return range;
    end

    function self:getAttackCost()
        return attackCost;
    end

    return self;
end

return Weapon;
