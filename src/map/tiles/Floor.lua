local BaseTile = require( 'src.map.tiles.BaseTile' );

local Floor = {};

function Floor.new( x, y, passable )
    local self = BaseTile.new( x, y, passable ):addInstance( 'Floor' );

    return self;
end

return Floor;
