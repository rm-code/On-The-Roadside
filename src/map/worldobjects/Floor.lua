local WorldObject = require( 'src.map.worldobjects.WorldObject' );

local Floor = {};

function Floor.new( passable )
    local self = WorldObject.new( passable ):addInstance( 'Floor' );

    return self;
end

return Floor;
