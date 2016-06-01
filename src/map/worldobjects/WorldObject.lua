local Object = require( 'src.Object' );

local WorldObject = {};

function WorldObject.new( type, passable, destructible )
    local self = Object.new():addInstance( 'WorldObject' );

    function self:isPassable()
        return passable;
    end

    function self:setPassable( npassable )
        passable = npassable;
    end

    function self:getMovementCost()
        return 1;
    end

    function self:getType()
        return type;
    end

    function self:isDestructible()
        return destructible;
    end

    return self;
end

return WorldObject;
