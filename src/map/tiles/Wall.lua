local BaseTile = require( 'src.map.tiles.BaseTile' );

local Wall = {};

function Wall.new( x, y, passable )
    local self = BaseTile.new( x, y, passable ):addInstance( 'Wall' );

    return self;
end

return Wall;
