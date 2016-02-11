local Object = require('src.Object');
local Queue = require('src.combat.Queue');

local Character = {};

function Character.new( tile )
    local self = Object.new():addInstance( 'Character' );

    self:validateType( 'Tile', tile, true );

    -- Add character to the tile.
    tile:setCharacter( self );

    local actions = Queue.new();

    function self:enqueueAction( action )
        actions:enqueue( action );
    end

    function self:dequeueAction()
        return actions:dequeue();
    end

    function self:hasAction()
        return actions:getSize() > 0;
    end

    function self:clearActions()
        actions:clear();
    end

    function self:setTile( ntile )
        tile = ntile;
    end

    function self:getTile()
        return tile;
    end

    return self;
end

return Character;
