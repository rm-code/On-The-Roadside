local Object = require( 'src.Object' );

local Magazine = {};

function Magazine.new( caliber, capacity )
    local self = Object.new():addInstance( 'Magazine' );

    local rounds = {};

    function self:addRound( nround )
        rounds[#rounds + 1] = nround;
    end

    function self:removeRound()
        table.remove( rounds, 1 );
    end

    function self:getRounds()
        return #rounds;
    end

    function self:getRound( i )
        return rounds[i];
    end

    function self:getCapacity()
        return capacity;
    end

    function self:getCaliber()
        return caliber;
    end

    function self:isFull()
        return #rounds == capacity;
    end

    function self:isEmpty()
        return #rounds == 0;
    end

    function self:setCapacity( ncapacity )
        capacity = ncapacity;
    end

    function self:serialize()
        local t = {};

        t['rounds'] = {}
        for i, round in ipairs( rounds ) do
            t['rounds'][i] = round:serialize();
        end

        return t;
    end

    return self;
end

return Magazine;
