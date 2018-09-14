---
-- This module is used by the map editor to store and handle the drawing grid.
-- @module PrefabCanvas
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Map = require( 'src.map.Map' )
local MapPainter = require( 'src.ui.MapPainter' )
local Grid = require( 'src.map.editor.Grid' )
local TileFactory = require( 'src.map.tiles.TileFactory' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabCanvas = Class( 'PrefabCanvas' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.DIRECTION' )
local PARCEL_SIZE = require( 'src.constants.PARCEL_SIZE' )
local PREFAB_SIZES = {
    XS = { TYPE = 'xs', WIDTH = 1, HEIGHT = 1 },
    S  = { TYPE = 's',  WIDTH = 2, HEIGHT = 2 },
    M  = { TYPE = 'm',  WIDTH = 4, HEIGHT = 4 },
    L  = { TYPE = 'l',  WIDTH = 6, HEIGHT = 6 },
    XL = { TYPE = 'xl', WIDTH = 7, HEIGHT = 7 }
}

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Fills the map with empty tiles.
-- @tparam Map map The map to fill.
-- @tparam number width  The Map's width.
-- @tparam number height The Map's height.
--
local function fillMap( map, width, height )
    for x = 1, width do
        for y = 1, height do
            map:setTileAt( x, y, TileFactory.create( 'tile_empty' ))
        end
    end
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function PrefabCanvas:initialize( size )
    self.size = size

    self.width  = PREFAB_SIZES[size].WIDTH  * PARCEL_SIZE.WIDTH
    self.height = PREFAB_SIZES[size].HEIGHT * PARCEL_SIZE.HEIGHT

    self.map = Map( self.width, self.height )
    fillMap( self.map, self.width, self.height )

    self.grid = Grid( self.width, self.height )

    self.mapPainter = MapPainter( self.map )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function PrefabCanvas:draw()
    self.mapPainter:draw()
    self.grid:draw( 16, 16 )
end

function PrefabCanvas:update()
    self.mapPainter:update()
end

function PrefabCanvas:toggleObjects()
    self.mapPainter:setWorldObjectsVisible( not self.mapPainter:getWorldObjectsVisible() )
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function PrefabCanvas:setSize( size )
    self:initialize( size )
end

function PrefabCanvas:setTile( x, y, id )
    local target = self.map:getTileAt( x, y )

    -- Stop early if we aren't on the grid.
    if not target then
        return
    end

    -- Only replace the target tile if it has a different id.
    if target:getID() == id then
        return
    end

    -- Create a new tile and copy the sprite id for the spritebatch.
    local tile = TileFactory.create( id )

    -- Place the tile on the map and mark it for rendering.
    self.map:setTileAt( x, y, tile )
    tile:setDirty( true )
end

function PrefabCanvas:setWorldObject( x, y, id )
    local tile = self.map:getTileAt( x, y )
    -- Stop early if we aren't on the grid.
    if not tile then
        return
    end

    -- Only replace the target tile if it has a different id.
    local target = self.map:getWorldObjectAt( x, y )
    if target and target:getID() == id then
        return
    end

    -- Remove old and create new world object and place it on the map.
    self.map:removeWorldObject( x, y, target )
    self.map:setWorldObjectAt( x, y, WorldObjectFactory.create( id ))

    -- Mark tile for rendering update.
    tile:setDirty( true )

    -- Mark neighbours for rendering update.
    local neighbours = tile:getNeighbours()
    if neighbours[DIRECTION.NORTH] then
        neighbours[DIRECTION.NORTH]:setDirty(true)
    end
    if neighbours[DIRECTION.EAST] then
        neighbours[DIRECTION.EAST]:setDirty(true)
    end
    if neighbours[DIRECTION.SOUTH] then
        neighbours[DIRECTION.SOUTH]:setDirty(true)
    end
    if neighbours[DIRECTION.WEST] then
        neighbours[DIRECTION.WEST]:setDirty(true)
    end
end

function PrefabCanvas:removeTile( x, y )
    local target = self.map:getTileAt( x, y )

    -- Stop early if we aren't on the grid.
    if not target then
        return
    end

    -- Create a new tile and copy the sprite id for the spritebatch.
    local tile = TileFactory.create( 'tile_empty' )

    -- Place the tile on the map and mark it for rendering.
    self.map:setTileAt( x, y, tile )
    tile:setDirty( true )
end

function PrefabCanvas:removeWorldObject( x, y )
    local tile = self.map:getTileAt( x, y )
    -- Stop early if we aren't on the grid.
    if not tile then
        return
    end

    -- Only replace the target tile if it has a different id.
    local target = self.map:getWorldObjectAt( x, y )
    if not target then
        return
    end

    self.map:removeWorldObject( x, y, target )
    tile:setDirty( true )

    -- Mark neighbours for rendering update.
    local neighbours = tile:getNeighbours()
    if neighbours[DIRECTION.NORTH] then
        neighbours[DIRECTION.NORTH]:setDirty(true)
    end
    if neighbours[DIRECTION.EAST] then
        neighbours[DIRECTION.EAST]:setDirty(true)
    end
    if neighbours[DIRECTION.SOUTH] then
        neighbours[DIRECTION.SOUTH]:setDirty(true)
    end
    if neighbours[DIRECTION.WEST] then
        neighbours[DIRECTION.WEST]:setDirty(true)
    end
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function PrefabCanvas:getTileAt( x, y )
    return self.map:getTileAt( x, y )
end

function PrefabCanvas:getWorldObjectAt( x, y )
    return self.map:getWorldObjectAt( x, y )
end

function PrefabCanvas:getWidth()
    return self.width
end

function PrefabCanvas:getHeight()
    return self.height
end

-- ------------------------------------------------
-- Serialization
-- ------------------------------------------------

function PrefabCanvas:deserialize( saved )
    self.size   = saved.size
    self.width  = saved.width
    self.height = saved.height

    self.map = Map( self.width, self.height )
    fillMap( self.map, self.width, self.height )

    for x = 1, #saved.grid do
        for y = 1, #saved.grid[x] do
            if saved.grid[x][y].tile then
                self:setTile( x, y, saved.grid[x][y].tile )
            end
            if saved.grid[x][y].worldObject then
                self:setWorldObject( x, y, saved.grid[x][y].worldObject )
            end
        end
    end

    self.grid = Grid( self.width, self.height )
    self.mapPainter = MapPainter( self.map )
end

function PrefabCanvas:serialize()
    local t = {
        size = self.size,
        width = self.width,
        height = self.height,
        grid = {}
    }

    self.map:iterate( function( x, y, tile, worldObject )
        t.grid[x] = t.grid[x] or {}
        t.grid[x][y] = {}

        if tile and tile:getID() ~= 'tile_empty' then
            t.grid[x][y].tile = tile:getID()
        end

        if worldObject then
            t.grid[x][y].worldObject = worldObject:getID()
        end
    end)

    return t
end

return PrefabCanvas
