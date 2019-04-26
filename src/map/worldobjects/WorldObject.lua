---
-- @module WorldObject
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local MapObject = require( 'src.map.MapObject' )
local Inventory = require( 'src.inventory.Inventory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local WorldObject = MapObject:subclass( 'WorldObject' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COVER_VALUES = {}
COVER_VALUES.NONE = 0
COVER_VALUES.HALF = 1
COVER_VALUES.FULL = 2

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes a new instance of the WorldObject class.
-- @tparam table template The WorldObject's template.
--
function WorldObject:initialize( template )
    MapObject.initialize( self )

    self.id = template.id
    self.height = template.size
    self.cover = template.cover
    self.interactionCost = template.interactionCost
    self.destructible = template.destructible
    self.debrisID = template.debrisID
    self.openable = template.openable or false
    self.climbable = template.climbable or false
    self.blocksPathfinding = template.blocksPathfinding
    self.container = template.container
    self.drops = template.drops

    self.group = template.group
    self.connections = template.connections

    self.hp = template.hp
    self.passable = template.passable or false
    self.blocksVision = template.blocksVision
    self.inventory = self.container and Inventory() or nil
end

---
-- Reduces the WorldObject's hit points.
-- @tparam number dmg The amount of damage that was dealt.
--
function WorldObject:damage( dmg )
    self.hp = self.hp - dmg

    if self.destructible and self.hp <= 0 then
        self.map:destroyWorldObject( self.x, self.y, self )
    end
end

---
-- Serializes the world object.
-- @treturn table The serialized world object.
--
function WorldObject:serialize()
    local t = {
        ['id'] = self.id,
        ['x'] = self.x,
        ['y'] = self.y,
        ['hp'] = self.hp,
        ['passable'] = self.passable,
        ['blocksVision'] = self.blocksVision
    }
    if self.container and not self.inventory:isEmpty() then
        t['inventory'] = self.inventory:serialize()
    end
    return t
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns true if the WorldObject should be ignored during pathfinding.
-- @treturn boolean True if it blocks pathfinding.
--
function WorldObject:doesBlockPathfinding()
    return self.blocksPathfinding
end

---
-- Returns true if the WorldObject blocks the line of sight.
-- @treturn boolean True if it blocks vision.
--
function WorldObject:doesBlockVision()
    return self.blocksVision
end

---
-- Returns the WorldObject id with which this WorldObject will be replaced
-- upon its destruction.
-- @treturn string The WorldObject id used for generating debris.
--
function WorldObject:getDebrisID()
    return self.debrisID
end

---
-- Checks wether this world object provides half cover.
-- @treturn boolean Wether or not this world object is half cover.
--
function WorldObject:isHalfCover()
    return self.cover == COVER_VALUES.HALF
end

---
-- Checks wether this world object provides full cover.
-- @treturn boolean Wether or not this world object is full cover.
--
function WorldObject:isFullCover()
    return self.cover == COVER_VALUES.FULL
end

---
-- Returns the WorldObject's hit points.
-- @treturn number The amount of hit points.
--
function WorldObject:getHitPoints()
    return self.hp
end

---
-- Returns the WorldObject's interaction cost attribute. The cost of interaction
-- is dependent on the stance a character is currently in.
-- @tparam  string stance The stance the character is currently in.
-- @treturn number        The amount of AP it costs to interact with this WorldObject.
--
function WorldObject:getInteractionCost( stance )
    if not self.interactionCost then
        return 0
    end
    return self.interactionCost[stance]
end

---
-- Returns this container's inventory.
-- @treturn Inventory The inventory.
--
function WorldObject:getInventory()
    return self.inventory
end

---
-- Returns the WorldObject's height attribute.
-- @treturn number The WorldObject's height.
--
function WorldObject:getHeight()
    return self.height
end

---
-- Returns the WorldObject's id.
-- @treturn string The WorldObject's id.
--
function WorldObject:getID()
    return self.id
end

---
-- Checks wether the WorldObject's can be climbed over (i.e.: Fences).
-- @treturn boolean True if the WorldObject is climbable.
--
function WorldObject:isClimbable()
    return self.climbable
end

---
-- Checks wether the WorldObject is a container.
-- @treturn boolean True if the WorldObject is a container.
--
function WorldObject:isContainer()
    return self.container
end

---
-- Checks wether the WorldObject's hit points have been reduced to zero.
-- @treturn boolean True if the WorldObject's hit points are less or equal zero.
--
function WorldObject:isDestroyed()
    return self.destructible and self.hp <= 0 or false
end

---
-- Gets the WorldObject's group.
-- @treturn string The group.
--
function WorldObject:getGroup()
    return self.group
end

---
-- Gets the WorldObject's connections.
-- @treturn table The connections.
--
function WorldObject:getConnections()
    return self.connections
end

---
-- Checks wether the WorldObject is destructible.
-- @treturn boolean True if the WorldObject is destructible.
--
function WorldObject:isDestructible()
    return self.destructible
end

---
-- Checks wether the WorldObject can be opened (i.e.: Doors, Gates, ...).
-- @treturn boolean True if the WorldObject is openable.
--
function WorldObject:isOpenable()
    return self.openable
end

---
-- Checks wether the WorldObject can be passed through by a Character.
-- @treturn boolean True if the WorldObject is passable.
--
function WorldObject:isPassable()
    return self.passable
end

---
-- Returns a table containing the possible drops for when this world object is
-- being destroyed.
-- @treturn table The drops.
--
function WorldObject:getDrops()
    return self.drops
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets the WorldObject's blocksVision attribute.
-- @tparam boolean blocksVision The new attribute value.
--
function WorldObject:setBlocksVision( blocksVision )
    self.blocksVision = blocksVision

    -- Send no update if the map isn't assembled already during map loading.
    if self:getMap() then
        self:publish( 'TILE_UPDATED', self:getTile() )
    end
end

---
-- Sets this WorldObject's hit points.
-- @tparam number hp The new hit point value.
--
function WorldObject:setHitPoints( hp )
    self.hp = hp
end

---
-- Sets the WorldObject's passable attribute.
-- @tparam boolean passable The new attribute value.
--
function WorldObject:setPassable( passable )
    self.passable = passable
end

return WorldObject
