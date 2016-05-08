local Tile = require( 'src.map.tiles.Tile' );

local Door = {};

function Door.new( x, y )
    local self = Tile.new( x, y, false ):addInstance( 'Door' );

    return self;
end

return Door;
