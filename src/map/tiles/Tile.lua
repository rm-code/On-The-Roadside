---
-- @module Tile
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Observable = require( 'src.util.Observable' )
local Inventory = require( 'src.inventory.Inventory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Tile = Observable:subclass( 'Tile' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEIGHT_LIMIT = 1000
local VOLUME_LIMIT = 1000
local DEFAULT_HEIGHT = 10

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new instance of the Tile class.
-- @tparam  number  x        The grid position along the x-axis.
-- @tparam  number  y        The grid position along the y-axis.
-- @tparam  string  id       The tile's id.
-- @tparam  number  cost     The amount of AP it costs to traverse this tile.
-- @tparam  boolean passable Wether this tile can be traversed.
-- @tparam  boolean spawn    Wether this tile is valid for spawning.
--
function Tile:initialize( x, y, id, cost, passable, spawn )
    Observable.initialize( self )

    self.x = x
    self.y = y

    self.id = id
    self.cost = cost
    self.passable = passable
    self.spawn = spawn

    self.inventory = Inventory( WEIGHT_LIMIT, VOLUME_LIMIT )
end

---
-- Adds a table containing the neighbouring tiles. Note that some tiles might
-- be nil.
-- @tparam table neighbours A table containing the neighbouring tiles.
--
function Tile:addNeighbours( neighbours )
    self.neighbours = neighbours
end

---
-- Adds a world object to this tile and marks it for a drawing update.
-- @tparam WorldObject worldObject The WorldObject to add.
--
function Tile:addWorldObject( worldObject )
    self.worldObject = worldObject
    self:setDirty( true )
end

---
-- Hits the tile with a certain amount of damage. The tile will distribute
-- the damage to any character or world object which it contains.
-- @tparam number damage     The damage the tile receives.
-- @tparam string damageType The type of damage the tile is hit with.
--
function Tile:hit( damage, damageType )
    if self:isOccupied() then
        self.character:hit( damage, damageType )
    elseif self:hasWorldObject() and self.worldObject:isDestructible() then
        self.worldObject:damage( damage, damageType )
    end
end

---
-- Removes the character from this tile and marks it for updating.
--
function Tile:removeCharacter()
    self.character = nil
    self:setDirty( true )
end

---
-- Removes the worldObject from this tile and marks it for updating.
--
function Tile:removeWorldObject()
    self.worldObject = nil
    self:setDirty( true )
end

---
-- Serializes the tile.
-- @treturn table The serialized Tile object.
--
function Tile:serialize()
    local t = {
        ['id'] = self.id,
        ['x'] = self.x,
        ['y'] = self.y
    }

    if self:hasWorldObject() then
        t.worldObject = self.worldObject:serialize()
    end

    if not self.inventory:isEmpty() then
        t['inventory'] = self.inventory:serialize()
    end

    return t
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the character standing on this tile.
-- @treturn Character The character standing on the tile.
--
function Tile:getCharacter()
    return self.character
end

---
-- Returns the tile's unique spriteID.
-- @treturn number The tile's spriteID.
--
function Tile:getSpriteID()
    return self.spriteID
end

---
-- Returns the cost it takes a character to traverse this tile.
-- @tparam  string stance The stance the character is currently in.
-- @treturn number        The movement cost for this tile.
--
function Tile:getMovementCost( stance )
    return self.cost[stance]
end

---
-- Returns a table containing this tile's neighbours.
-- @treturn table A table containing the neighbouring tiles.
--
function Tile:getNeighbours()
    return self.neighbours
end

---
-- Returns the tile's grid position.
-- @treturn number The tile's position along the x-axis of the grid.
-- @treturn number The tile's position along the y-axis of the grid.
--
function Tile:getPosition()
    return self.x, self.y
end

---
-- Gets the tile's inventory.
-- @treturn Inventory The tile's inventory.
--
function Tile:getInventory()
    return self.inventory
end

---
-- Returns the height of the tile. If it contains a character or a
-- worldObject it returns the size of those, if not it returns a default
-- value.
-- @treturn number The height of this tile.
--
function Tile:getHeight()
    if self.worldObject then
        return self.worldObject:getHeight()
    elseif self.character then
        return self.character:getHeight()
    end
    return DEFAULT_HEIGHT
end

---
-- Returns the tile's ID.
-- @treturn string The tile's ID.
--
function Tile:getID()
    return self.id
end

---
-- Returns the world object located on this tile.
-- @treturn WorldObject The WorldObject.
--
function Tile:getWorldObject()
    return self.worldObject
end

---
-- Returns the tile's grid position along the x-axis.
-- @treturn number The tile's position along the x-axis of the grid.
--
function Tile:getX()
    return self.x
end

---
-- Returns the tile's grid position along the y-axis.
-- @treturn number The tile's position along the y-axis of the grid.
--
function Tile:getY()
    return self.y
end

---
-- Checks if the tile has a world object.
-- @treturn boolean True if a WorldObject is located on the tile.
--
function Tile:hasWorldObject()
    return self.worldObject ~= nil
end

---
-- Checks if a given tile is adjacent to this tile.
-- @treturn boolean True if the tiles are adjacent to each other.
--
function Tile:isAdjacent( tile )
    for _, neighbour in pairs( self.neighbours ) do
        if neighbour == tile then
            return true
        end
    end
end

---
-- Checks if the tile is marked for an update.
-- @treturn boolean True if the tile is dirty.
--
function Tile:isDirty()
    return self.dirty
end

---
-- Checks if the tile has a character on it.
-- @treturn boolean True a character is standing on the tile.
--
function Tile:isOccupied()
    return self.character ~= nil
end

---
-- Checks if the tile is passable.
-- @treturn boolean True if the tile is passable.
--
function Tile:isPassable()
    if self.passable and self:hasWorldObject() then
        return self.worldObject:isPassable()
    end
    return self.passable
end

---
-- Determines wether the tile is valid for spawning.
-- @treturn boolean True if the tile is valid for spawning.
--
function Tile:isSpawn()
    return self.spawn
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets a character for this tile and marks the tile for updating.
-- @tparam Character character The character to add.
--
function Tile:setCharacter( character )
    self.character = character
    self:setDirty( true )
end

---
-- Sets the dirty state of the tile.
-- @tparam boolean dirty Wether the tile should be updated or not.
--
function Tile:setDirty( dirty )
    self.dirty = dirty
end

---
-- Sets the tile's unique spriteID.
-- @tparam number id The tile's new spriteID.
--
function Tile:setSpriteID( id )
    self.spriteID = id
end

return Tile
