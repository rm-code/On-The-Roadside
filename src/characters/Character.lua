local Object = require('src.Object');
local Queue = require('src.Queue');
local ItemFactory = require('src.items.ItemFactory');
local Inventory = require('src.inventory.Inventory');

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

    local inventory = Inventory.new();
    inventory:equipItem( ItemFactory.createWeapon() );
    inventory:equipItem( ItemFactory.createBag() );
    inventory:equipItem( ItemFactory.createClothing( CLOTHING_SLOTS.HEADGEAR ));
    inventory:equipItem( ItemFactory.createClothing( CLOTHING_SLOTS.GLOVES   ));
    inventory:equipItem( ItemFactory.createClothing( CLOTHING_SLOTS.SHIRT    ));
    inventory:equipItem( ItemFactory.createClothing( CLOTHING_SLOTS.JACKET   ));
    inventory:equipItem( ItemFactory.createClothing( CLOTHING_SLOTS.TROUSERS ));
    inventory:equipItem( ItemFactory.createClothing( CLOTHING_SLOTS.FOOTWEAR ));

    inventory:getBackpack():getStorage():addItem( ItemFactory.createClothing( CLOTHING_SLOTS.HEADGEAR ));

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

        local clothing = inventory:getClothingItem( bodyPart );
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
    -- Returns the faction the character belongs to.
    -- @return (number) The faction's index.
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
    -- Returns the view range.
    -- @return (number) The view range.
    --
    function self:getViewRange()
        return 12;
    end

    ---
    -- Returns the currently equipped weapon.
    -- @return (Weapon) The weapon.
    --
    function self:getWeapon()
        return inventory:getPrimaryWeapon();
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
