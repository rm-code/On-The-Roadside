local Item = require( 'src.items.Item' );

local Magazine = {};

function Magazine.new( id, itemType, ammoType )
    local self = Item.new( id, itemType ):addInstance( 'Magazine' );

    local capacity = 0;
    local rounds = 0;

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
        return id;
    end

    function self:getAmmoType()
        return ammoType;
    end

    function self:isFull()
        return rounds == capacity;
    end

    function self:isEmpty()
        return rounds == 0;
    end

    function self:setRounds( nrounds )
        rounds = nrounds;
    end

    function self:setCapacity( ncapacity )
        capacity = ncapacity;
    end

    function self:serialize()
        local t = {
            ['id'] = id,
            ['itemType'] = itemType,
            ['rounds'] = rounds,
            ['capacity'] = capacity
        }
        return t;
    end

    return self;
end

return Magazine;
