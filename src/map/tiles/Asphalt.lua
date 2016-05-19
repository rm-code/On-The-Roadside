local Tile = require( 'src.map.tiles.Tile' );

local Asphalt = {};

function Asphalt.new( x, y )
    return Tile.new( x, y, 1 ):addInstance( 'Asphalt' );
end

return Asphalt;
