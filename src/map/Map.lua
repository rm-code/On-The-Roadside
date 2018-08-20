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
-- Observers each tile so the map can receive events from them.
-- @tparam Map   self  The map instance to use.
-- @tparam table tiles A table containing all of the Map's tiles.
--
local function observeTiles( self, tiles )
    for x = 1, #tiles do
        for y = 1, #tiles[x] do
            tiles[x][y]:observe( self )
        end
    end
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
-- Updates the map. This resets the visibility attribute for all visible
-- tiles and marks them for a drawing update. It also replaces destroyed
-- WorldObjects with their debris types or removes them completely.
--
function Map:update()
    for x = 1, #self.tiles do
        for y = 1, #self.tiles[x] do
            local tile = self.tiles[x][y]
            if tile:hasWorldObject() and tile:getWorldObject():isDestroyed() then
                -- Create items from the destroyed object.
                for _, drop in ipairs( tile:getWorldObject():getDrops() ) do
                    local id, tries, chance = drop.id, drop.tries, drop.chance
                    for _ = 1, tries do
                        if love.math.random( 100 ) < chance then
                            local item = ItemFactory.createItem( id )
                            tile:getInventory():addItem( item )
                        end
                    end
                end

                -- If the world object was a container drop the items in it.
                if tile:getWorldObject():isContainer() and not tile:getWorldObject():getInventory():isEmpty() then
                    local items = tile:getWorldObject():getInventory():getItems()
                    for _, item in pairs( items ) do
                        tile:getInventory():addItem( item )
                    end
                end

                -- If the world object has a debris object, place that on the tile.
                if tile:getWorldObject():getDebrisID() then
                    local nobj = WorldObjectFactory.create( tile:getWorldObject():getDebrisID() )
                    tile:removeWorldObject()
                    tile:addWorldObject( nobj )
                else
                    tile:removeWorldObject()
                end
                self:publish( 'TILE_UPDATED', tile )
            end
        end
    end
end

function Map:receive( event, ... )
    self:publish( event, ... )
end

function Map:serialize()
    local t = {
        width = self.width,
        height = self.height,
        tiles = {}
    }

    for x = 1, #self.tiles do
        for y = 1, #self.tiles[x] do
            table.insert( t.tiles, self.tiles[x][y]:serialize() )
        end
    end

    return t
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
    -- Remove character from old position if necessary.
    local oldX, oldY = character:getPosition()
    if oldX and oldY then
        self.characters[oldX][oldY] = nil
    end

    -- Make sure the grid space is empty.
    if self.characters[x][y] ~= nil then
        error( string.format( 'Target position (%s, %s) is already occupied by a character.', x, y ))
    end

    -- Add character to new position.
    self.characters[x][y] = character

    character:setPosition( x, y )
    character:setMap( self )
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
end

---
-- Sets a worldObject to a specific position on the worldObject layer.
-- @tparam number      x The target position along the x-axis.
-- @tparam number      y The target position along the y-axis.
-- @tparam WorldObject   The worldObject to set to the grid.
--
function Map:setWorldObjectAt( x, y, worldObject )
    self.worldObjects[x][y] = worldObject

    worldObject:setPosition( x, y )
    worldObject:setMap( self )
end

---
-- TODO remove!
--
function Map:initializeGrid()
    observeTiles( self, self.tiles )
end

---
-- Sets the spawnpoints for this map.
-- @tparam table spawnpoints The spawnpoints for all factions on this map.
--
function Map:setSpawnpoints( spawnpoints )
    self.spawnpoints = spawnpoints
end

return Map
