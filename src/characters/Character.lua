local Object = require('src.Object');
local Queue = require('src.combat.Queue');

local DEFAULT_ACTION_POINTS = 20;

local Character = {};

function Character.new( tile, faction )
    local self = Object.new():addInstance( 'Character' );

    self:validateType( 'Tile', tile, true );

    local path;
    local actionPoints = DEFAULT_ACTION_POINTS;

    -- Add character to the tile.
    tile:addCharacter( self );

    local actions = Queue.new();

    function self:enqueueAction( action )
        actions:enqueue( action );
    end

    function self:performAction()
        local action = actions:dequeue();
        actionPoints = actionPoints - action:getCost();
        action:perform();
    end

    function self:canPerformAction()
        return actions:getSize() > 0 and actions:peek():getCost() <= actionPoints;
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

    function self:resetActionPoints()
        actionPoints = DEFAULT_ACTION_POINTS;
    end

    function self:getActionPoints()
        return actionPoints;
    end

    function self:getFaction()
        return faction;
    end

    function self:getViewRange()
        return 12;
    end

    return self;
end

return Character;
