local BaseTile = require( 'src.map.tiles.BaseTile' );

local Door = {};

function Door.new( x, y )
    local self = BaseTile.new( x, y, false ):addInstance( 'Door' );

    return self;
end

return Door;
