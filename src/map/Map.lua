---
-- @module Map
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Observable = require( 'src.util.Observable' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )
local ItemFactory = require( 'src.items.ItemFactory' )
local Tile = require( 'src.map.tiles.Tile' )
local WorldObject = require( 'src.map.worldobjects.WorldObject' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Map = Observable:subclass( 'Map' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.DIRECTION' )

local DIRECTION_MODIFIERS = {
    [DIRECTION.NORTH]      = { x =  0, y = -1 },
    [DIRECTION.SOUTH]      = { x =  0, y =  1 },
    [DIRECTION.EAST]       = { x =  1, y =  0 },
    [DIRECTION.WEST]       = { x = -1, y =  0 },
    [DIRECTION.NORTH_EAST] = { x =  1, y = -1 },
    [DIRECTION.NORTH_WEST] = { x = -1, y = -1 },
    [DIRECTION.SOUTH_EAST] = { x =  1, y =  1 },
    [DIRECTION.SOUTH_WEST] = { x = -1, y =  1 }
}

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Compiles a list of all neighbouring tiles around a certain coordinate.
-- @tparam Map    self The map instance to use.
-- @tparam number x    The tile position along the x-axis.
-- @tparam number y    The tile position along the y-axis.
-- @treturn table      A list of all neighbouring tiles.
--
local function createTileNeighbours( self, x, y )
    local neighbours = {}
    for direction, modifier in ipairs( DIRECTION_MODIFIERS ) do
        neighbours[direction] = self:getTileAt( x + modifier.x, y + modifier.y )
    end
    return neighbours
end

---
-- Compiles a list of all neighbouring worldObjects around a certain coordinate.
-- @tparam Map    self The map instance to use.
-- @tparam number x    The tile position along the x-axis.
-- @tparam number y    The tile position along the y-axis.
-- @treturn table      A list of all neighbouring worldObjects.
--
local function createWorldObjectNeighbours( self, x, y )
    local neighbours = {}
    for direction, modifier in ipairs( DIRECTION_MODIFIERS ) do
        neighbours[direction] = self:getWorldObjectAt( x + modifier.x, y + modifier.y )
    end
    return neighbours
end

---
-- Creates an empty two dimensional array.
-- @return table The newly created grid.
--
local function createEmptyGrid( width, height )
    local grid = {}
    for x = 1, width do
        for y = 1, height do
            grid[x] = grid[x] or {}
            grid[x][y] = nil
        end
    end
    return grid
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes a new Map instance.
-- @tparam number width  The Map's width.
-- @tparam number height The Map's height.
--
function Map:initialize( width, height )
    Observable.initialize( self )

    self.tiles        = createEmptyGrid( width, height )
    self.worldObjects = createEmptyGrid( width, height )
    self.characters   = createEmptyGrid( width, height )

    self.width = width
    self.height = height
end

---
-- Iterates over all tiles and performs the callback function on them.
-- @tparam function callback The operation to perform on each tile.
--
function Map:iterate( callback )
    for x = 1, self.width do
        for y = 1, self.height do
            callback( x, y, self.tiles[x][y], self.worldObjects[x][y], self.characters[x][y] )
        end
    end
end

---
-- Randomly searches for a tile on which a creature could be spawned.
-- @tparam  string faction The faction id to spawn a creature for.
-- @treturn Tile           A tile suitable for spawning.
--
function Map:findSpawnPoint( faction )
    for _ = 1, 2000 do
        local index = love.math.random( #self.spawnpoints[faction] )
        local spawn = self.spawnpoints[faction][index]

        local tile = self:getTileAt( spawn.x, spawn.y )
        if tile:isSpawn() and tile:isPassable() and not tile:hasCharacter() then
            return tile
        end
    end
    error( string.format( 'Can not find a valid spawnpoint at position!' ))
end

---
-- Receives events published by Observables.
-- @tparam string event A string by which the message can be identified.
-- @tparam varargs ...  Multiple parameters to push to the receiver.
--
function Map:receive( event, ... )
    self:publish( event, ... )
end

---
-- Moves a Character from his current position to a new target position.
-- @tparam number    x         The target position along the x-axis.
-- @tparam number    y         The target position along the y-axis.
-- @tparam Character character The character to move.
--
function Map:moveCharacter( x, y, character )
    -- Remove character from old position.
    self:removeCharacter( character:getX(), character:getY(), character )

    -- Set character to new position.
    self:setCharacterAt( x, y, character )
end

---
-- Removes a Character from a specific position on the character layer.
-- @tparam number    x         The target position along the x-axis.
-- @tparam number    y         The target position along the y-axis.
-- @tparam Character character The character to remove from the grid.
--
function Map:removeCharacter( x, y, character )
    if character ~= self.characters[x][y] then
        error( string.format( 'Character at position (%s, %s) does not match the character to remove.', x, y ))
    end

    self.characters[x][y] = nil
end

---
-- Removes a WorldObject from a specific position on the worldObject layer.
-- @tparam number      x           The target position along the x-axis.
-- @tparam number      y           The target position along the y-axis.
-- @tparam WorldObject worldObject The worldObject to remove from the grid.
--
function Map:removeWorldObject( x, y, worldObject )
    if worldObject ~= self.worldObjects[x][y] then
        error( string.format( 'WorldObject at position (%s, %s) does not match the WorldObject to remove.', x, y ))
    end

    self.worldObjects[x][y] = nil
end

---
-- Destroys a WorldObject at a specific position on the worldObject layer.
-- @tparam number      x           The target position along the x-axis.
-- @tparam number      y           The target position along the y-axis.
-- @tparam WorldObject worldObject The worldObject to destroy.
--
function Map:destroyWorldObject( x, y, worldObject )
    local tile = self:getTileAt( x, y )

    -- Create items from the destroyed object.
    for _, drop in ipairs( worldObject:getDrops() ) do
        local id, tries, chance = drop.id, drop.tries, drop.chance
        for _ = 1, tries do
            if love.math.random( 100 ) < chance then
                tile:getInventory():addItem( ItemFactory.createItem( id ))
            end
        end
    end

    -- If the world object is a container, drop any contained items.
    if worldObject:isContainer() and not worldObject:getInventory():isEmpty() then
        for _, item in pairs( worldObject:getInventory():getItems() ) do
            tile:getInventory():addItem( item )
        end
    end

    -- Remove the object from the map.
    self:removeWorldObject( x, y, worldObject )

    -- Place a debris object if the destroyed world object has one.
    if worldObject:getDebrisID() then
        self:setWorldObjectAt( x, y, WorldObjectFactory.create( worldObject:getDebrisID() ))
    end

    self:publish( 'TILE_UPDATED', tile )
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the Character at the given coordinates.
-- @tparam  number    x The position along the x-axis.
-- @tparam  number    y The position along the y-axis.
-- @treturn Character   The Character at the given position.
--
function Map:getCharacterAt( x, y )
    return self.characters[x] and self.characters[x][y]
end

---
-- Returns the Tile at the given coordinates.
-- @tparam  number x The position along the x-axis.
-- @tparam  number y The position along the y-axis.
-- @treturn Tile     The Tile at the given position.
--
function Map:getTileAt( x, y )
    return self.tiles[x] and self.tiles[x][y]
end

---
-- Returns the WorldObject at the given coordinates.
-- @tparam  number      x The position along the x-axis.
-- @tparam  number      y The position along the y-axis.
-- @treturn WorldObject   The WorldObject at the given position.
--
function Map:getWorldObjectAt( x, y )
    return self.worldObjects[x] and self.worldObjects[x][y]
end

---
-- Returns the map's dimensions.
-- @treturn number The map's width.
-- @treturn number The map's height.
--
function Map:getDimensions()
    return self.width, self.height
end

---
-- Returns the neighbours around a specific position.
-- @tparam number    x      The position along the x-axis.
-- @tparam number    y      The position along the y-axis.
-- @tparam MapObject object The map object to return neighbours for.
--
function Map:getNeighbours( x, y, object )
    if object:isInstanceOf( Tile ) then
        return createTileNeighbours( self, x, y )
    elseif object:isInstanceOf( WorldObject ) then
        return createWorldObjectNeighbours( self, x, y )
    end
    error( 'Not a valid object to get neighbours for!' )
end


---
-- Returns the neighbour in the specific direction around a certain position.
-- @tparam number    x      The position along the x-axis.
-- @tparam number    y      The position along the y-axis.
-- @tparam MapObject object The map object to return the neighbour for.
-- @tparam string    dir    The direction to get the neighbour from.
--
function Map:getNeighbour( x, y, object, dir )
    if object:isInstanceOf( Tile ) then
        return self:getTileAt( x + DIRECTION_MODIFIERS[dir].x, y + DIRECTION_MODIFIERS[dir].y )
    elseif object:isInstanceOf( WorldObject ) then
        return self:getWorldObjectAt( x + DIRECTION_MODIFIERS[dir].x, y + DIRECTION_MODIFIERS[dir].y )
    end
    error( 'Not a valid object to get neighbours for!' )
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets a Character to a specific position on the character layer.
-- @tparam number      x The target position along the x-axis.
-- @tparam number      y The target position along the y-axis.
-- @tparam Character     The character to set to the grid.
--
function Map:setCharacterAt( x, y, character )
    -- Make sure the grid space is empty.
    if self.characters[x][y] ~= nil then
        error( string.format( 'Target position (%s, %s) is already occupied by a character.', x, y ))
    end

    -- Add character to new position.
    self.characters[x][y] = character

    character:setPosition( x, y )
    character:setMap( self )

    character:observe( self )
end

---
-- Sets a tile to a specific position on the tile layer.
-- @tparam number x    The target position along the x-axis.
-- @tparam number y    The target position along the y-axis.
-- @tparam Tile   tile The tile to set to the grid.
--
function Map:setTileAt( x, y, tile )
    self.tiles[x][y] = tile

    tile:setPosition( x, y )
    tile:setMap( self )

    tile:observe( self )
end

---
-- Sets a worldObject to a specific position on the worldObject layer.
-- @tparam number      x The target position along the x-axis.
-- @tparam number      y The target position along the y-axis.
-- @tparam WorldObject   The worldObject to set to the grid.
--
function Map:setWorldObjectAt( x, y, worldObject )
    -- Make sure the grid space is empty.
    if self.worldObjects[x][y] ~= nil then
        error( string.format( 'Target position (%s, %s) is already occupied by a WorldObject.', x, y ))
    end

    self.worldObjects[x][y] = worldObject

    worldObject:setPosition( x, y )
    worldObject:setMap( self )

    worldObject:observe( self )
end

---
-- Sets the spawnpoints for this map.
-- @tparam table spawnpoints The spawnpoints for all factions on this map.
--
function Map:setSpawnpoints( spawnpoints )
    self.spawnpoints = spawnpoints
end

-- ------------------------------------------------
-- Serialization
-- ------------------------------------------------

---
-- Serializes the Map instance.
-- @treturn table The serialized character instance.
--
function Map:serialize()
    local t = {
        ['width'] = self.width,
        ['height'] = self.height,
        ['tiles'] = {},
        ['worldObjects'] = {},
        ['characters'] = {}
    }

    self:iterate( function( _, _, tile, worldObject, character )
        t.tiles[#t.tiles + 1] = tile:serialize()

        if worldObject then
            t.worldObjects[#t.worldObjects + 1] = worldObject:serialize()
        end

        if character then
            t.characters[#t.characters + 1] = character:serialize()
        end
    end)

    return t
end

return Map
