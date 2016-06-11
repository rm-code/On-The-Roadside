local Object = require( 'src.Object' );

local WorldObject = {};

function WorldObject.new( template )
    local self = Object.new():addInstance( 'WorldObject' );

    local name = template.name;
    local type = template.type;
    local passable = template.passable;
    local blocksPathfinding = template.blocksPathfinding;
    local destructible = template.destructible;

    function self:blocksPathfinding()
        return blocksPathfinding;
    end

    function self:isPassable()
        return passable;
    end

    function self:setPassable( npassable )
        passable = npassable;
    end

    function self:getMovementCost()
        return 1;
    end

    function self:getName()
        return name;
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
