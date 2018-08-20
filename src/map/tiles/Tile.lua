---
-- @module Tile
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local MapObject = require( 'src.map.MapObject' )
local Inventory = require( 'src.inventory.Inventory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Tile = MapObject:subclass( 'Tile' )

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
-- @tparam  string  id       The tile's id.
-- @tparam  number  cost     The amount of AP it costs to traverse this tile.
-- @tparam  boolean passable Wether this tile can be traversed.
-- @tparam  boolean spawn    Wether this tile is valid for spawning.
--
function Tile:initialize( id, cost, passable, spawn )
    MapObject.initialize( self )

    self.id = id
    self.cost = cost
    self.passable = passable
    self.spawn = spawn

    self.inventory = Inventory( WEIGHT_LIMIT, VOLUME_LIMIT )
end

---
-- Hits the tile with a certain amount of damage. The tile will distribute
-- the damage to any character or world object which it contains.
-- @tparam number damage     The damage the tile receives.
-- @tparam string damageType The type of damage the tile is hit with.
--
function Tile:hit( damage, damageType )
    if self:hasCharacter() then
        self:getCharacter():hit( damage, damageType )
    elseif self:hasWorldObject() and self:getWorldObject():isDestructible() then
        self:getWorldObject():damage( damage, damageType )
    end
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
        t.worldObject = self:getWorldObject():serialize()
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
    if self:getWorldObject() then
        return self:getWorldObject():getHeight()
    elseif self:getCharacter() then
        return self:getCharacter():getHeight()
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
-- Checks if a given tile is adjacent to this tile.
-- @treturn boolean True if the tiles are adjacent to each other.
--
function Tile:isAdjacent( tile )
    for _, neighbour in pairs( self:getNeighbours() ) do
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
-- Checks if the tile is passable.
-- @treturn boolean True if the tile is passable.
--
function Tile:isPassable()
    if self.passable and self:hasWorldObject() then
        return self:getWorldObject():isPassable()
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
