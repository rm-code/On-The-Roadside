local Object = require('src.Object');
local Queue = require('src.turnbased.Queue');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DEFAULT_ACTION_POINTS = 20;

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Character = {};

---
-- Creates a new character and places it on the target tile.
-- @param tile    (Tile)      The tile to spawn the character on.
-- @param faction (number)    The index determining the character's faction.
-- @return        (Character) A new instance of the Character class.
--
function Character.new( tile, faction )
    local self = Object.new():addInstance( 'Character' );

    -- Add character to the tile.
    tile:addCharacter( self );

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local path;
    local lineOfSight;
    local actionPoints = DEFAULT_ACTION_POINTS;
    local actions = Queue.new();
    local dead = false;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Adds a new action to the action queue.
    -- @param action (Action) The action to enqueue.
    --
    function self:enqueueAction( action )
        actions:enqueue( action );
    end

    ---
    -- Removes the next action from the action queue, reduces the action points
    -- of the character by the action's cost and performs the action.
    --
    function self:performAction()
        local action = actions:dequeue();
        actionPoints = actionPoints - action:getCost();
        action:perform();
    end

    ---
    -- Checks if the next action in the queue can be performed.
    -- @return (boolean) Wether the action can be performed.
    --
    function self:canPerformAction()
        return actions:getSize() > 0 and actions:peek():getCost() <= actionPoints;
    end

    ---
    -- Cleas the action queue.
    --
    function self:clearActions()
        actions:clear();
    end

    ---
    -- Resets the character's action points to the default value.
    --
    function self:resetActionPoints()
        actionPoints = DEFAULT_ACTION_POINTS;
    end

    ---
    -- Adds a new path for the character.
    -- @param path (Path) The path to add.
    --
    function self:addPath( npath )
        if path then
            path:refresh();
        end
        path = npath;
    end

    ---
    -- Removes the current path.
    --
    function self:removePath()
        path = nil;
    end

    ---
    -- Adds a new line of sight for the character.
    -- @param nlos (LineOfSight) The line of sight to add.
    --
    function self:addLineOfSight( nlos )
        lineOfSight = nlos;
    end

    ---
    -- Removes the current line of sight.
    --
    function self:removeLineOfSight()
        lineOfSight = nil;
    end

    ---
    -- Hits the character with damage.
    --
    function self:hit()
        -- TODO proper hit and damage calculations.
        dead = true;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the amount of action points.
    -- @return (number) The amount of action points.
    --
    function self:getActionPoints()
        return actionPoints;
    end

    ---
    -- Returns the faction the character belongs to.
    -- @return (number) The faction's index.
    --
    function self:getFaction()
        return faction;
    end

    ---
    -- Returns the line of sight.
    -- @return (LineOfSight) The character's current line of sight.
    --
    function self:getLineOfSight()
        return lineOfSight;
    end

    ---
    -- Returns the current path.
    -- @return (Path) The current path.
    --
    function self:getPath()
        return path;
    end

    ---
    -- Gets the character's tile.
    -- @return (Tile) The tile the character is located on.
    --
    function self:getTile()
        return tile;
    end

    ---
    -- Checks if the character currently has a line of sight.
    -- @return (boolean) Wether the character has a line of sight.
    --
    function self:hasLineOfSight()
        return lineOfSight ~= nil;
    end

    ---
    -- Checks if the character currently has a path.
    -- @return (boolean) Wether the character has a path.
    --
    function self:hasPath()
        return path ~= nil;
    end

    ---
    -- Returns the view range.
    -- @return (number) The view range.
    --
    function self:getViewRange()
        return 12;
    end

    ---
    -- Returns wether the character is dead or not.
    -- @return (boolean) Wether the character is dead or not.
    --
    function self:isDead()
        return dead;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    ---
    -- Sets the character's tile.
    -- @param tile (Tile) The tile to set the character to.
    --
    function self:setTile( ntile )
        tile = ntile;
    end

    return self;
end

return Character;
