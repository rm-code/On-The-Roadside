local BaseTile = require( 'src.map.tiles.BaseTile' );

local Wall = {};

function Wall.new( x, y )
    local self = BaseTile.new( x, y, false ):addInstance( 'Wall' );

    return self;
end

return Wall;
