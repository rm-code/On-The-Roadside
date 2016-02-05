local WorldObject = require( 'src.map.worldobjects.WorldObject' );

local Wall = {};

function Wall.new( passable )
    local self = WorldObject.new( passable ):addInstance( 'Wall' );

    return self;
end

return Wall;
