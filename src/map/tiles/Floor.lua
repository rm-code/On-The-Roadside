local BaseTile = require( 'src.map.tiles.BaseTile' );

local Floor = {};

function Floor.new( x, y )
    local self = BaseTile.new( x, y, true ):addInstance( 'Floor' );

    return self;
end

return Floor;
