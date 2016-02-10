local Object = require('src.Object');

local Character = {};

function Character.new( tile )
    local self = Object.new():addInstance( 'Character' );

    self:validateType( 'Tile', tile, true );

    -- Add character to the tile.
    tile:setCharacter( self );

    function self:setTile( ntile )
        tile = ntile;
    end

    function self:getTile()
        return tile;
    end

    return self;
end

return Character;
