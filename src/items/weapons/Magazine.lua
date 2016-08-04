local Item = require( 'src.items.Item' );

local Magazine = {};

function Magazine.new( caliber, itemType, damageType, capacity )
    local self = Item.new( caliber, itemType ):addInstance( 'Magazine' );

    local rounds = capacity;

    function self:removeShell()
        rounds = rounds - 1;
    end

    function self:getRounds()
        return rounds;
    end

    function self:getCapacity()
        return capacity;
    end

    function self:getCaliber()
        return caliber;
    end

    function self:getDamageType()
        return damageType;
    end

    function self:isFull()
        return rounds == capacity;
    end

    function self:isEmpty()
        return rounds == 0;
    end

    return self;
end

return Magazine;
