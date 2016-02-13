local Object = require('src.Object');
local Queue = require('src.combat.Queue');

local Character = {};

function Character.new( tile )
    local self = Object.new():addInstance( 'Character' );

    self:validateType( 'Tile', tile, true );

    local path;

    -- Add character to the tile.
    tile:setCharacter( self );

    local actions = Queue.new();

    function self:enqueueAction( action )
        actions:enqueue( action );
    end

    function self:performAction()
        local action = actions:dequeue();
        action:perform();
    end

    function self:canPerformAction()
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

    function self:addPath( npath )
        if path then
            path:refresh();
        end
        path = npath;
    end

    function self:getPath()
        return path;
    end

    function self:hasPath()
        return path ~= nil;
    end

    return self;
end

return Character;
