local BaseTile = require( 'src.map.tiles.BaseTile' );

local Door = {};

function Door.new( x, y, passable )
    local self = BaseTile.new( x, y, passable ):addInstance( 'Door' );

    local open = false;

    function self:isOpen()
        return open;
    end

    function self:setOpen( nopen )
        open = nopen;
    end

    return self;
end

return Door;
