local Object = require( 'src.Object' );

local WorldObject = {};

function WorldObject.new( template )
    local self = Object.new():addInstance( 'WorldObject' );

    local name = template.name;
    local type = template.type;
    local passable = template.passable;
    local blocksPathfinding = template.blocksPathfinding;
    local blocksVision = template.blocksVision;
    local destructible = template.destructible;
    local size = template.size;
    local movementCost = template.movementCost;
    local debrisType = template.debrisType;

    function self:blocksPathfinding()
        return blocksPathfinding;
    end

    function self:blocksVision()
        return blocksVision;
    end

    function self:isPassable()
        return passable;
    end

    function self:getSize()
        return size;
    end

    -- TODO rename
    function self:setBlocksVision( nblocksVision )
        blocksVision = nblocksVision;
    end

    function self:setPassable( npassable )
        passable = npassable;
    end

    function self:getDebrisType()
        return debrisType;
    end

    function self:getMovementCost()
        return movementCost;
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
