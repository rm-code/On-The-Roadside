local Object = require('src.Object');
local Queue = require('src.util.Queue');
local ItemFactory = require('src.items.ItemFactory');
local Equipment = require('src.characters.Equipment');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DEFAULT_ACTION_POINTS = 20;

local CLOTHING_SLOTS = require('src.constants.ClothingSlots');

local BODY_PARTS = {
    CLOTHING_SLOTS.HEADGEAR,
    CLOTHING_SLOTS.GLOVES,
    CLOTHING_SLOTS.JACKET,
    CLOTHING_SLOTS.SHIRT,
    CLOTHING_SLOTS.TROUSERS,
    CLOTHING_SLOTS.FOOTWEAR
}

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Character = {};

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

    local path;
    local lineOfSight;
    local actionPoints = DEFAULT_ACTION_POINTS;
    local actions = Queue.new();
    local fov = {};

    local equipment = Equipment.new();

    -- TODO move to different class
    local weapon = ItemFactory.createWeapon();
    local magazine = ItemFactory.createMagazine( weapon:getAmmoType(), 30 );
    weapon:reload( magazine );
    equipment:addItem( weapon );
    equipment:addItem( ItemFactory.createBag() );
    equipment:addItem( ItemFactory.createClothing( CLOTHING_SLOTS.HEADGEAR ));
    equipment:addItem( ItemFactory.createClothing( CLOTHING_SLOTS.GLOVES   ));
    equipment:addItem( ItemFactory.createClothing( CLOTHING_SLOTS.SHIRT    ));
    equipment:addItem( ItemFactory.createClothing( CLOTHING_SLOTS.JACKET   ));
    equipment:addItem( ItemFactory.createClothing( CLOTHING_SLOTS.TROUSERS ));
    equipment:addItem( ItemFactory.createClothing( CLOTHING_SLOTS.FOOTWEAR ));

    local accuracy = love.math.random( 60, 90 );
    local health = love.math.random( 50, 100 );

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
        tile:getInventory():addItem( equipment:getWeapon() );
        tile:getInventory():addItem( equipment:getBackpack() );

        for _, part in pairs( BODY_PARTS ) do
            tile:getInventory():addItem( equipment:getClothingItem( part ));
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

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
        actionPoints = actionPoints - action:getCost();
        action:perform();
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

                -- Add tile to faction's map of explored tiles.
                faction:addExploredTile( tx, ty, target );

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
        if path then
            path:refresh();
        end
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
    -- @param damage (number) The amount of damage the character is hit with.
    --
    function self:hit( damage )
        -- Randomly determine the body part which was hit by the attack and
        -- get the clothing item on that body part.
        local bodyPart = BODY_PARTS[love.math.random( #BODY_PARTS )];

        -- Randomly increases or reduces the base damage by 15%.
        local flukeModifier = math.floor( damage * randomSign() * ( love.math.random( 15 ) / 100 ));
        damage = damage + flukeModifier;

        local clothing = equipment:getClothingItem( bodyPart );
        if clothing:isArmor() then
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

    -- TODO remove
    function self:getBackpack()
        return equipment:getBackpack()
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
    -- Returns the character's equipment.
    -- @return (Inventory) The character's equipment.
    --
    function self:getEquipment()
        return equipment;
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
    -- Returns the character's fov.
    -- @return (table) A table containing the tiles this character sees.
    --
    function self:getFOV()
        return fov;
    end

    ---
    -- Gets the character's tile.
    -- @return (Tile) The tile the character is located on.
    --
    function self:getTile()
        return tile;
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
    -- Returns the currently equipped weapon.
    -- @return (Weapon) The weapon.
    -- TODO remove
    function self:getWeapon()
        return self:getEquipment():getWeapon();
    end

    ---
    -- Checks if the character has an action enqueued.
    -- @return (boolean) Wether an action is enqueued.
    --
    function self:hasEnqueuedAction()
        return actions:getSize() > 0;
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
    -- Sets the character's tile.
    -- @param tile (Tile) The tile to set the character to.
    --
    function self:setTile( ntile )
        tile = ntile;
    end

    return self;
end

return Character;
