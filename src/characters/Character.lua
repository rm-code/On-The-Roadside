local Object = require('src.Object');

local Character = {};

function Character.new( tile )
    local self = Object.new():addInstance( 'Character' );

    self:validateType( 'BaseTile', tile, true );

    local action;

    -- Add character to the tile.
    tile:setCharacter( self );

    function self:setTile( ntile )
        tile = ntile;
    end

    function self:getTile()
        return tile;
    end

    function self:setAction( naction )
        action = naction;
    end

    function self:getAction()
        return action;
    end

    return self;
end

return Character;
