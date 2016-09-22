local Object = require('src.Object');
local Queue = require('src.util.Queue');
local Inventory = require('src.inventory.Inventory');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Character = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DEFAULT_ACTION_POINTS = 20;

local STANCES = require('src.constants.Stances');

local ITEM_TYPES = require('src.constants.ItemTypes');
local BODY_PARTS = {
    ITEM_TYPES.HEADGEAR,
    ITEM_TYPES.GLOVES,
    ITEM_TYPES.JACKET,
    ITEM_TYPES.SHIRT,
    ITEM_TYPES.TROUSERS,
    ITEM_TYPES.FOOTWEAR
}

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

    local inventory = Inventory.new();

    local accuracy = love.math.random( 60, 90 );
    local health = love.math.random( 50, 100 );

    local stance = STANCES.STAND;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    --
    -- Returns a random sign (+ or -).
    -- @return (number) Randomly returns either -1 or 1.
    --
    local function randomSign()
        return love.math.random( 0, 1 ) == 0 and -1 or 1;
    end

    ---
    -- Drops this character's inventory on the ground.
    --
    local function dropInventory()
        tile:getInventory():addItem( inventory:getItem( ITEM_TYPES.WEAPON ));
        tile:getInventory():addItem( inventory:getItem( ITEM_TYPES.BAG ));

        for _, part in pairs( BODY_PARTS ) do
            print(part)
            tile:getInventory():addItem( inventory:getItem( part ));
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
        local success = action:perform();
        if success then
            actionPoints = actionPoints - action:getCost();
        end
        self:generateFOV();
    end

    ---
    -- Checks if the character has enough action points to perform the next
    -- action in the queue.
    -- @return (boolean) Wether the action can be performed.
    --
    function self:canPerformAction()
        return actions:peek():getCost() <= actionPoints;
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
        self:resetFOV();

        local range = self:getViewRange();

        -- Calculate the new FOV information.
        for i = 1, 360 do
            local ox, oy = tile:getX() + 0.5, tile:getY() + 0.5;
            local rad    = math.rad( i );
            local rx, ry = math.cos( rad ), math.sin( rad );

            for _ = 1, range do
                local target = map:getTileAt( math.floor( ox ), math.floor( oy ));
                if not target then
                    break;
                end
                local tx, ty = target:getPosition();

                -- Add tile to this character's FOV.
                self:addSeenTile( tx, ty, target );

                -- Mark tile as explored for this character's faction.
                target:setExplored( faction:getType(), true );

                -- Mark tile for drawing update.
                target:setDirty( true );

                if target:hasWorldObject() and target:getWorldObject():blocksVision() then
                    break;
                end

                ox = ox + rx;
                oy = oy + ry;
            end
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
    --
    function self:hit( damage )
        -- Randomly determine the body part which was hit by the attack and
        -- get the clothing item on that body part.
        local bodyPart = BODY_PARTS[love.math.random( #BODY_PARTS )];

        -- Randomly increases or reduces the base damage by 15%.
        local flukeModifier = math.floor( damage * randomSign() * ( love.math.random( 15 ) / 100 ));
        damage = damage + flukeModifier;

        local clothing = inventory:getItem( bodyPart );
        if clothing then
            if love.math.random( 0, 100 ) < clothing:getArmorCoverage() then
                print( "Hit armor. Damage reduced by " .. clothing:getArmorProtection() );
                damage = damage - clothing:getArmorProtection();
            end
        end

        -- Prevent negative damage.
        damage = math.max( damage, 0 );

        print( "Damage: " .. damage );

        health = health - damage;

        if self:isDead() then
            dropInventory();
            tile:removeCharacter();
            self:resetFOV();
        end
    end

    ---
    -- Clears the list of seen tiles and marks them for a drawing update.
    --
    function self:resetFOV()
        for x, rx in pairs( fov ) do
            for y, target in pairs( rx ) do
                target:setDirty( true );
                fov[x][y] = nil;
            end
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

    function self:serialize()
        local t = {
            ['ap'] = actionPoints,
            ['accuracy'] = accuracy,
            ['health'] = health,
            ['stance'] = stance,
            ['inventory'] = inventory:serialize(),
            ['faction'] = faction:getType()
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
    -- Returns the faction the character belongs to.
    -- @return (Faction) The Faction object.
    --
    function self:getFaction()
        return faction;
    end

    ---
    -- Returns the character's current health.
    -- @return (number) The character's health.
    --
    function self:getHealth()
        return health;
    end

    ---
    -- Returns the character's inventory.
    -- @return (Inventory) The character's inventory.
    --
    function self:getInventory()
        return inventory;
    end

    ---
    -- Returns the character's fov.
    -- @return (table) A table containing the tiles this character sees.
    --
    function self:getFOV()
        return fov;
    end

    ---
    -- Returns the character's current stance.
    -- @return (number) The character's stance.
    --
    function self:getStance()
        return stance;
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
        return health <= 0;
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
    -- Sets the character's health.
    -- @param nhp (number) The new health value.
    --
    function self:setHealth( nhp )
        health = nhp;
    end

    ---
    -- Sets the character's tile.
    -- @param tile (Tile) The tile to set the character to.
    --
    function self:setTile( ntile )
        tile = ntile;
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
