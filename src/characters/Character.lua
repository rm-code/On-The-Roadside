local Log = require( 'src.util.Log' );
local Object = require('src.Object');
local Queue = require('src.util.Queue');
local Bresenham = require( 'lib.Bresenham' );
local Util = require( 'src.util.Util' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Character = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DEFAULT_ACTION_POINTS = 40;

local STANCES = require( 'src.constants.STANCES' )
local ITEM_TYPES = require('src.constants.ITEM_TYPES')

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new character and places it on the target tile.
-- @param map     (Map)       A reference to the map object.
-- @param tile    (Tile)      The tile to spawn the character on.
-- @param faction (Faction)   The Faction object determining the character's faction.
-- @return        (Character) A new instance of the Character class.
--
function Character.new( map, tile, faction )
    local self = Object.new():addInstance( 'Character' );

    -- Add character to the tile.
    tile:addCharacter( self );

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local actionPoints = DEFAULT_ACTION_POINTS;
    local actions = Queue.new();
    local fov = {};

    local accuracy = love.math.random( 60, 90 );
    local throwingSkill = love.math.random( 60, 90 );

    local stance = STANCES.STAND;
    local body;

    local finishedTurn = false;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Marks a tile as seen by this character if it fullfills the necessary
    -- requirements. Used as a callback for Bresenham's line algorithm.
    -- @tparam  number  cx      The tile's coordinate along the x-axis.
    -- @tparam  number  cy      The tile's coordinate along the y-axis.
    -- @tparam  number  counter The number of tiles touched by the ray so far.
    -- @tparam  number  falloff Determines how much height the ray loses each step.
    -- @treturn boolean         Returns true if the tile can be seen by the character.
    --
    local function markSeenTiles( cx, cy, counter, falloff )
        local target = map:getTileAt( cx, cy );
        if not target then
            return false;
        end

        -- Calculate the height of the ray on the current tile. If the height
        -- is smaller than the tile's height it is marked as visible. This
        -- simulates how small objects can be hidden behind bigger objects, but
        -- not the other way around.
        local height = self:getHeight() - (counter+1) * falloff
        if height <= target:getHeight() then
            -- Add tile to this character's FOV.
            self:addSeenTile( cx, cy, target );

            -- Mark tile as explored for this character's faction.
            target:setExplored( faction:getType(), true );

            -- Mark tile for drawing update.
            target:setDirty( true );
        end

        -- A world object blocks vision if it has the "blocksVision" flag set
        -- to true in its template file and if the ray is smaller than the world
        -- object's size. This prevents characters from looking over bigger world
        -- objects and allows smaller objects like low walls to cast a "shadow"
        -- in which smaller objects could be hidden.
        if  target:hasWorldObject()
        and target:getWorldObject():blocksVision()
        and height <= target:getWorldObject():getHeight() then
            return false;
        end

        return true;
    end

    ---
    -- Determine the height falloff for rays of the FOV calculation. This value
    -- will be deducted from the ray's height for each tile the ray traverses.
    -- @tparam  Tile   The target tile.
    -- @tparam  number The distance to the target.
    -- @treturn number The calculated falloff value.
    --
    local function calculateFalloff( target, steps )
        local oheight = self:getHeight()
        local theight = target:getHeight()

        local delta = oheight - theight;
        return delta / steps;
    end

    ---
    -- Clears the list of seen tiles and marks them for a drawing update.
    --
    local function resetFOV()
        for x, rx in pairs( fov ) do
            for y, target in pairs( rx ) do
                target:setDirty( true );
                fov[x][y] = nil;
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Called when this character is made active by the game.
    --
    function self:activate()
        if self:isDead() then
            return;
        end
        self:generateFOV();
        self:clearActions();
    end

    ---
    -- Adds a tile to this character's FOV.
    -- @param tx     (number) The target-tile's position along the x-axis.
    -- @param ty     (number) The target-tile's position along the y-axis.
    -- @param target (Tile)   The target-tile.
    --
    function self:addSeenTile( tx, ty, target )
        fov[tx] = fov[tx] or {};
        fov[tx][ty] = target;
    end

    ---
    -- Adds a new action to the action queue if the character has enough action
    -- points to perform it.
    -- @param naction (Action) The action to enqueue.
    -- @return       (boolean) True if the action was enqueued.
    --
    function self:enqueueAction( naction )
        local cost = 0;
        for _, action in ipairs( actions:getItems() ) do
            cost = cost + action:getCost();
        end

        if cost + naction:getCost() <= actionPoints then
            actions:enqueue( naction );
            return true;
        end

        Log.debug( 'No AP left. Refused to add Action to Queue.', 'Character' );
        return false;
    end

    ---
    -- Removes the next action from the action queue, reduces the action points
    -- of the character by the action's cost and performs the action.
    --
    function self:performAction()
        local action = actions:dequeue();
        local success = action:perform();
        if success then
            actionPoints = actionPoints - action:getCost();
        end
        self:generateFOV();
    end

    ---
    -- Cleas the action queue.
    --
    function self:clearActions()
        actions:clear();
    end

    ---
    -- Called when this character is made inactive by the game.
    --
    function self:deactivate()
        if self:isDead() then
            return;
        end
        self:generateFOV();
        self:clearActions();
    end

    ---
    -- Casts rays in a circle around the character to determine all tiles he can
    -- see. Rays stop if they reach the map border or a world object which has
    -- the blocksVision attribute set to true.
    --
    function self:generateFOV()
        resetFOV()

        local range = body:getStatusEffects():isBlind() and 1 or self:getViewRange();
        local list = Util.getTilesInCircle( map, tile, range );
        local sx, sy = tile:getPosition();

        for _, ttile in ipairs( list ) do
            local tx, ty = ttile:getPosition();
            local _, counter = Bresenham.line( sx, sy, tx, ty );
            local falloff = calculateFalloff( ttile, counter );
            Bresenham.line( sx, sy, tx, ty, markSeenTiles, falloff );
        end
    end

    ---
    -- Resets the character's action points to the default value.
    --
    function self:resetActionPoints()
        actionPoints = DEFAULT_ACTION_POINTS;
    end

    ---
    -- Hits the character with damage.
    -- @param damage (number) The amount of damage the character is hit with.
    -- @param damageType (string) The type of damage the tile is hit with.
    --
    function self:hit( damage, damageType )
        body:hit( damage, damageType );

        self:generateFOV();

        if self:isDead() then
            self:getEquipment():dropAllItems( tile );
            self:getInventory():dropAllItems( tile );
            tile:removeCharacter();
            resetFOV()
        end
    end

    ---
    -- Checks if the character can see a certain tile.
    -- @param target (Tile)    The tile to check.
    -- @return       (boolean) Wether the character sees the tile.
    --
    function self:canSee( target )
        local tx, ty = target:getPosition();
        if not fov[tx] then
            return false;
        end
        return fov[tx][ty] ~= nil;
    end

    function self:tickOneTurn()
        body:tickOneTurn();
        if self:isDead() then
            self:getEquipment():dropAllItems( tile );
            tile:removeCharacter();
            resetFOV()
        end
    end

    function self:serialize()
        local t = {
            ['actionPoints'] = actionPoints,
            ['accuracy'] = accuracy,
            ['throwingSkill'] = throwingSkill,
            ['stance'] = stance,
            ['finishedTurn'] = finishedTurn,
            ['body'] = body:serialize(),
            ['x'] = tile:getX(),
            ['y'] = tile:getY()
        }
        return t;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the accuracy of this character used when shooting guns.
    -- @return (number) The accuracy of the character.
    --
    function self:getAccuracy()
        return accuracy;
    end

    ---
    -- Returns the amount of action points.
    -- @return (number) The amount of action points.
    --
    function self:getActionPoints()
        return actionPoints;
    end

    ---
    -- Returns the action queue.
    -- @return (table) A sequence containing all actions.
    --
    function self:getActions()
        return actions:getItems();
    end

    ---
    -- Returns the action queue.
    -- @return (Queue) A queue containing all actions.
    --
    function self:getActionQueue()
        return actions;
    end

    function self:getBody()
        return body;
    end

    ---
    -- Returns the faction the character belongs to.
    -- @return (Faction) The Faction object.
    --
    function self:getFaction()
        return faction;
    end

    ---
    -- Returns the character's equipment.
    -- @return (Equipment) The character's equipment.
    --
    function self:getEquipment()
        return body:getEquipment();
    end

    ---
    -- Returns the character's inventory.
    -- @return (Equipment) The character's inventory.
    --
    function self:getInventory()
        return body:getInventory();
    end

    ---
    -- Returns the character's fov.
    -- @return (table) A table containing the tiles this character sees.
    --
    function self:getFOV()
        return fov;
    end

    ---
    -- Returns the character's size based on his stance.
    -- @return (number) The character's size.
    --
    function self:getHeight()
        return body:getHeight( stance )
    end

    ---
    -- Returns the character's current stance.
    -- @return (number) The character's stance.
    --
    function self:getStance()
        return stance;
    end

    ---
    -- Gets the character's throwing skill.
    -- @return (number) The character's throwing skill.
    --
    function self:getThrowingSkill()
        return throwingSkill;
    end

    ---
    -- Gets the character's tile.
    -- @return (Tile) The tile the character is located on.
    --
    function self:getTile()
        return tile;
    end

    ---
    -- Returns the game's map.
    -- @return (Map) The map the character is existing on.
    --
    function self:getMap()
        return map;
    end

    ---
    -- Returns the total amount of action points.
    -- @return (number) The total amount of action points.
    --
    function self:getMaxActionPoints()
        return DEFAULT_ACTION_POINTS;
    end

    ---
    -- Returns the view range.
    -- @return (number) The view range.
    --
    function self:getViewRange()
        return 12;
    end

    ---
    -- Checks if the character has an action enqueued.
    -- @return (boolean) Wether an action is enqueued.
    --
    function self:hasEnqueuedAction()
        return actions:getSize() > 0;
    end

    ---
    -- Returns wether the character is dead or not.
    -- @return (boolean) Wether the character is dead or not.
    --
    function self:isDead()
        return body:getStatusEffects():isDead();
    end

    ---
    -- Gets an item of type weapon.
    -- @return (Weapon) The weapon item.
    --
    function self:getWeapon()
        return self:getEquipment():getItem( ITEM_TYPES.WEAPON );
    end

    ---
    -- Gets wether the character has finished a turn or not.
    -- @return (boolean) Wether the character has finished a turn or not.
    --
    function self:hasFinishedTurn()
        return finishedTurn;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    ---
    -- Sets the character's accuracy attribute.
    -- @param naccuracy (number) The new accuracy value.
    --
    function self:setAccuracy( naccuracy )
        accuracy = naccuracy;
    end

    ---
    -- Sets the character's action points.
    -- @param nap (number) The amount of AP to set.
    --
    function self:setActionPoints( nap )
        actionPoints = nap;
    end

    ---
    -- Sets the character's new body.
    -- @param nbody (Body) The body object to use.
    --
    function self:setBody( nbody )
        body = nbody;
    end

    ---
    -- Sets the character's tile.
    -- @param tile (Tile) The tile to set the character to.
    --
    function self:setTile( ntile )
        tile = ntile;
    end

    function self:setThrowingSkill( nthrowingSkill )
        throwingSkill = nthrowingSkill;
    end

    ---
    -- Sets if the character is done with a turn. This is used by the AI handler
    -- to determine if the character is viable for another update.
    -- @param tile (Tile) The tile to set the character to.
    --
    function self:setFinishedTurn( nfinished )
        finishedTurn = nfinished;
    end

    ---
    -- Sets the character's stance.
    -- @param nstance (number) The character's new stance.
    --
    function self:setStance( nstance )
        stance = nstance;
    end

    return self;
end

return Character;
