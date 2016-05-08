local Tile = require( 'src.map.tiles.Tile' );

local Wall = {};

function Wall.new( x, y )
    local self = Tile.new( x, y, false ):addInstance( 'Wall' );

    return self;
end

return Wall;
