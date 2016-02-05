local Object = require( 'src.Object' );

local WorldObject = {};

function WorldObject.new( passable )
    local self = Object.new():addInstance( 'WorldObject' );

    function self:isPassable()
        return passable;
    end

    function self:setPassable( npassable )
        passable = npassable;
    end

    return self;
end

return WorldObject;
