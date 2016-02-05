local WorldObject = require( 'src.map.worldobjects.WorldObject' );

local Door = {};

function Door.new( passable )
    local self = WorldObject.new( passable ):addInstance( 'Door' );

    return self;
end

return Door;
