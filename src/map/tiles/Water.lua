local Tile = require( 'src.map.tiles.Tile' );

local Water = {};

function Water.new( x, y )
    return Tile.new( x, y, 3 ):addInstance( 'Water' );
end

return Water;
