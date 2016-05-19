local WorldObject = require( 'src.map.worldobjects.WorldObject' );

local Wall = {};

function Wall.new()
    local self = WorldObject.new( false, false ):addInstance( 'Wall' );

    return self;
end

return Wall;
