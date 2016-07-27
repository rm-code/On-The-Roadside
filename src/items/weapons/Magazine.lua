local Object = require( 'src.Object' );

local Magazine = {};

function Magazine.new( ammoType, capacity )
    local self = Object.new():addInstance( 'Magazine' );

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

    function self:getAmmoType()
        return ammoType;
    end

    function self:isEmpty()
        return rounds == 0;
    end

    return self;
end

return Magazine;
