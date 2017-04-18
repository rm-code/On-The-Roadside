local Object = require( 'src.Object' );
local Inventory = require( 'src.inventory.Inventory' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local WorldObject = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new instance of the WorldObject class.
-- @param template (table)       The WorldObject's template.
-- @return         (WorldObject) The new WorldObject.
--
function WorldObject.new( template )
    local self = Object.new():addInstance( 'WorldObject' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local id = template.id;
    local height = template.size
    local interactionCost = template.interactionCost;
    local energyReduction = template.energyReduction;
    local destructible = template.destructible;
    local debrisID = template.debrisID;
    local openable = template.openable or false;
    local climbable = template.climbable or false;
    local blocksPathfinding = template.blocksPathfinding;
    local container = template.container;
    local drops = template.drops;

    local hp = template.hp;
    local passable = template.passable or false;
    local blocksVision = template.blocksVision;
    local inventory = container and Inventory.new() or nil;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Reduces the WorldObject's hit points.
    -- @param dmg (number) The amount of damage that was dealt.
    --
    function self:damage( dmg )
        hp = hp - dmg;
    end

    function self:serialize()
        local t = {
            ['id'] = id,
            ['hp'] = hp,
            ['passable'] = passable,
            ['blocksVision'] = blocksVision
        }
        if container and not inventory:isEmpty() then
            t['inventory'] = inventory:serialize();
        end
        return t;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns true if the WorldObject should be ignored during pathfinding.
    -- @return (boolean) True if it blocks pathfinding.
    --
    function self:blocksPathfinding()
        return blocksPathfinding;
    end

    ---
    -- Returns true if the WorldObject blocks the line of sight.
    -- @return (boolean) True if it blocks vision.
    --
    function self:blocksVision()
        return blocksVision;
    end

    ---
    -- Returns the WorldObject id with which this WorldObject will be replaced
    -- upon its destruction.
    -- @return (string) The WorldObject id used for generating debris.
    --
    function self:getDebrisID()
        return debrisID;
    end

    ---
    -- Returns the WorldObject's energy reduction attribute. This is used to
    -- reduce the amount of force a projectile has after passing through this
    -- WorldObject.
    -- @return (number) The WorldObject's energy reduction value.
    --
    function self:getEnergyReduction()
        return energyReduction;
    end

    ---
    -- Returns the WorldObject's hit points.
    -- @return (number) The amount of hit points.
    --
    function self:getHitPoints()
        return hp;
    end

    ---
    -- Returns the WorldObject's interaction cost attribute. The cost of interaction
    -- is dependent on the stance a character is currently in.
    -- @param  stance (string) The stance the character is currently in.
    -- @return        (number) The amount of AP it costs to interact with this WorldObject.
    --
    function self:getInteractionCost( stance )
        if not interactionCost then
            return 0;
        end
        return interactionCost[stance];
    end

    ---
    -- Returns this container's inventory.
    -- @return (Inventory) The inventory.
    --
    function self:getInventory()
        return inventory;
    end

    ---
    -- Returns the WorldObject's height attribute.
    -- @return (number) The WorldObject's height.
    --
    function self:getHeight()
        return height
    end

    ---
    -- Returns the WorldObject's id.
    -- @return (string) The WorldObject's id.
    --
    function self:getID()
        return id;
    end

    ---
    -- Checks wether the WorldObject's can be climbed over (i.e.: Fences).
    -- @return (boolean) True if the WorldObject is climbable.
    --
    function self:isClimbable()
        return climbable;
    end

    ---
    -- Checks wether the WorldObject is a container.
    -- @return (boolean) True if the WorldObject is a container.
    --
    function self:isContainer()
        return container;
    end

    ---
    -- Checks wether the WorldObject's hit points have been reduced to zero.
    -- @return (boolean) True if the WorldObject's hit points are less or equal zero.
    --
    function self:isDestroyed()
        return destructible and hp <= 0 or false;
    end

    ---
    -- Checks wether the WorldObject is destructible.
    -- @return (boolean) True if the WorldObject is destructible.
    --
    function self:isDestructible()
        return destructible;
    end

    ---
    -- Checks wether the WorldObject can be opened (i.e.: Doors, Gates, ...).
    -- @return (boolean) True if the WorldObject is openable.
    --
    function self:isOpenable()
        return openable;
    end

    ---
    -- Checks wether the WorldObject can be passed through by a Character.
    -- @return (boolean) True if the WorldObject is passable.
    --
    function self:isPassable()
        return passable;
    end

    function self:getDrops()
        return drops;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    ---
    -- Sets the WorldObject's blocksVision attribute.
    -- @param nblocksVision (boolean) The new attribute value.
    --
    function self:setBlocksVision( nblocksVision )
        blocksVision = nblocksVision;
    end

    ---
    -- Sets this WorldObject's hit points.
    -- @param nhp (number) The new hit point value.
    --
    function self:setHitPoints( nhp )
        hp = nhp;
    end

    ---
    -- Sets the WorldObject's passable attribute.
    -- @param npassable (boolean) The new attribute value.
    --
    function self:setPassable( npassable )
        passable = npassable;
    end

    return self;
end

return WorldObject;
