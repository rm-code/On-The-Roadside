local Object = require( 'src.Object' );

local Weapon = {};

function Weapon.new()
    local self = Object.new():addInstance( 'Weapon' );

    -- TODO: Load custom weapon stats from templates.
    local damage = love.math.random( 3, 5 );
    local range  = love.math.random( 10, 15 );
    local attackCost = love.math.random( 3, 5 );

    local accuracy = love.math.random( 80, 90 );

    function self:getAccuracy()
        return accuracy;
    end

    function self:getDamage()
        return damage;
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
