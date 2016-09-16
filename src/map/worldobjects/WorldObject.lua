local Object = require( 'src.Object' );

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

    local name = template.name;
    local type = template.type;
    local size = template.size;
    local hp = template.hp;
    local interactionCost = template.interactionCost;
    local energyReduction = template.energyReduction;
    local destructible = template.destructible;
    local debrisType = template.debrisType;
    local openable = template.openable or false;
    local climbable = template.climbable or false;
    local passable = template.passable or false;
    local blocksVision = template.blocksVision;
    local blocksPathfinding = template.blocksPathfinding;
    local sprite = template.sprite;
    local openSprite = template.openSprite;
    local color = template.color;

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
            ['type'] = type,
            ['passable'] = passable,
            ['blocksVision'] = blocksVision,
            ['hp'] = hp
        }
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
    -- Returns a table containing the RGB values for this WorldObject.
    -- @return (table) The table containing the RGB values.
    --
    function self:getColor()
        return color;
    end

    ---
    -- Returns the WorldObject type with which this WorldObject will be replaced
    -- upon its destruction.
    -- @return (string) The WorldObject type used for generating debris.
    --
    function self:getDebrisType()
        return debrisType;
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
    -- Returns the WorldObject's interaction cost attribute.
    -- @return (number) The amount of AP it costs to interact with this WorldObject.
    --
    function self:getInteractionCost()
        return interactionCost;
    end

    ---
    -- Returns the WorldObject's name.
    -- @return (string) The WorldObject's human readable name.
    --
    function self:getName()
        return name;
    end

    ---
    -- Returns the WorldObject's size attribute.
    -- @return (number) The WorldObject's size.
    --
    function self:getSize()
        return size;
    end

    ---
    -- Returns the WorldObject's sprite index.
    -- @return (number) The WorldObject's sprite index.
    --
    function self:getSprite()
        if openable and passable then
            return openSprite;
        end
        return sprite;
    end

    ---
    -- Returns the WorldObject's id.
    -- @return (string) The WorldObject's id.
    --
    function self:getType()
        return type;
    end

    ---
    -- Checks wether the WorldObject's can be climbed over (i.e.: Fences).
    -- @return (boolean) True if the WorldObject is climbable.
    --
    function self:isClimbable()
        return climbable;
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
