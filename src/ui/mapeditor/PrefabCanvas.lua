---
-- This module is used by the map editor to store and handle the drawing grid.
-- @module PrefabCanvas
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local TileFactory = require( 'src.map.tiles.TileFactory' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabCanvas = Class( 'PrefabCanvas' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local PREFAB_SIZES = {
    XS = { TYPE = 'xs', WIDTH =  8, HEIGHT =  8 }, -- 1x1
    S  = { TYPE = 's',  WIDTH = 16, HEIGHT = 16 }, -- 2x2
    M  = { TYPE = 'm',  WIDTH = 32, HEIGHT = 32 }, -- 4x4
    L  = { TYPE = 'l',  WIDTH = 48, HEIGHT = 48 }, -- 6x6
    XL = { TYPE = 'xl', WIDTH = 56, HEIGHT = 56 }  -- 7x7
}

local CONNECTION_BITMASK = {
    [0]  = 'default',

    -- Straight connections-
    [1]  = 'vertical', -- North
    [4]  = 'vertical', -- South
    [5]  = 'vertical', -- North South
    [2]  = 'horizontal', -- East
    [8]  = 'horizontal', -- West
    [10] = 'horizontal', -- East West

    -- Corners.
    [3]  = 'ne',
    [9]  = 'nw',
    [6]  = 'se',
    [12] = 'sw',

    -- T Intersection
    [7]  = 'nes',
    [11] = 'new',
    [13] = 'nws',
    [14] = 'sew',

    -- + Intersection
    [15] = 'news',
}

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Creates an empty grid of the given dimensions.
-- @treturn table The empty grid.
--
local function createGrid( width, height )
    local ngrid = {}
    for x = 1, width do
        for y = 1, height do
            ngrid[x] = ngrid[x] or {}
            ngrid[x][y] = {}
        end
    end
    return ngrid
end

---
-- Draws the grid lines of the editor.
-- @tparam table  grid The two-dimensional array containing the grid.
-- @tparam number tw   The width of each grid cell in pixels.
-- @tparam number th   The width of each grid cell in pixels.
--
local function drawGridLines( grid, tw, th )
    TexturePacks.setColor( 'ingame_editor_grid_lines')
    for x = 1, #grid do
        for y = 1, #grid[x] do
            love.graphics.rectangle( 'line', x * tw, y * th, tw, th )
        end
    end
    TexturePacks.resetColor()
end

---
-- Checks wether there is an adjacent world object with a group that matches the
-- connections of the original world object.
-- @tparam  table  connections The connections table containing the groups the world object connects to.
-- @tparam  Tile   neighbour   The neighbouring tile to check for a matching world object.
-- @tparam  number value       The value to return in case the world object matches.
-- @treturn number             The value indicating a match (0 if the world object doesn't match).
--
local function checkConnection( connections, neighbour, value )
    if neighbour and neighbour.worldObject then
        local group = neighbour.worldObject.group
        if group then
            for i = 1, #connections do
                if connections[i] == group then
                    return value
                end
            end
        end
    end
    return 0
end

---
-- Selects the tile to use for drawing a worldobject.
-- @tparam  PrefabCanvas self     The PrefabCanvas instance to use.
-- @tparam  table        template The world object template to use for drawing.
-- @tparam  number       x        The world object's position along the x-axis.
-- @tparam  number       y        The world object's position along the y-axis.
-- @treturn Quad                  A quad pointing to the sprite on the active tileset.
--
local function selectWorldObjectSprite( self, template, x, y )
    if template.openable then
        return TexturePacks.getSprite( template.id, 'closed' )
    end

    -- Check if the world object sprite connects to adjacent sprites.
    if template.connections then
        local result = checkConnection( template.connections, self:getTile( x, y - 1 ), 1 ) +
                       checkConnection( template.connections, self:getTile( x + 1, y ), 2 ) +
                       checkConnection( template.connections, self:getTile( x, y + 1 ), 4 ) +
                       checkConnection( template.connections, self:getTile( x - 1, y ), 8 )
        return TexturePacks.getSprite( template.id, CONNECTION_BITMASK[result] )
    end

    return TexturePacks.getSprite( template.id )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function PrefabCanvas:initialize( size )
    self.size = size
    self.width, self.height = PREFAB_SIZES[self.size].WIDTH, PREFAB_SIZES[self.size].HEIGHT
    self.grid = createGrid( self.width, self.height )

    -- self.hideObjects
    -- self.highlightWorldObjects
    -- self.highlightTiles
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function PrefabCanvas:draw()
    local tw, th = TexturePacks.getTileDimensions()

    drawGridLines( self.grid, tw, th )

    for x = 1, #self.grid do
        for y = 1, #self.grid[x] do
            -- Draw tile layer.
            if self.grid[x][y].tile then
                local tileID = self.grid[x][y].tile.id
                TexturePacks.setColor( tileID )
                love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), TexturePacks.getSprite( tileID ), x * tw, y * tw )
            end


            -- Draw worldobject layer.
            if self.grid[x][y].worldObject and not self.hideObjects then
                local template = self.grid[x][y].worldObject
                local worldObjectID = template.id
                TexturePacks.setColor( 'sys_background' )
                love.graphics.rectangle( 'fill', x * tw, y * th, tw, th )

                local sprite = selectWorldObjectSprite( self, template, x, y )

                TexturePacks.setColor( worldObjectID )
                love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), sprite, x * tw, y * th )
            end
        end
    end
end

function PrefabCanvas:setTile( x, y, type, content )
    if self.grid[x] and self.grid[x][y] then
        self.grid[x][y][type] = content
    end
end

function PrefabCanvas:getTile( x, y )
    return self.grid[x] and self.grid[x][y]
end

function PrefabCanvas:getTileID( x, y, type )
    if self.grid[x][y][type] then
        return self.grid[x][y][type].id
    end
    return 'empty'
end

function PrefabCanvas:exists( x, y )
    if self.grid[x] and self.grid[x][y] then
        return true
    end
    return false
end

function PrefabCanvas:serialize()
    local t = {
        size = self.size,
        width = self.width,
        height = self.height,
        grid = {}
    }

    for x = 1, #self.grid do
        for y = 1, #self.grid[x] do
            t.grid[x] = t.grid[x] or {}
            t.grid[x][y] = {
                tile = self.grid[x][y].tile and self.grid[x][y].tile.id or nil,
                worldObject = self.grid[x][y].worldObject and self.grid[x][y].worldObject.id or nil
            }
        end
    end

    return t
end

function PrefabCanvas:load( saved )
    self.size   = saved.size
    self.width  = saved.width
    self.height = saved.height
    self.grid = createGrid( self.width, self.height )

    for x = 1, #self.grid do
        for y = 1, #self.grid[x] do
            if saved.grid[x][y].tile then
                self.grid[x][y].tile = TileFactory.getTemplates()[saved.grid[x][y].tile]
            end
            if saved.grid[x][y].worldObject then
                self.grid[x][y].worldObject = WorldObjectFactory.getTemplates()[saved.grid[x][y].worldObject]
            end
        end
    end
end

function PrefabCanvas:getWidth()
    return self.width
end

function PrefabCanvas:getHeight()
    return self.height
end

function PrefabCanvas:setSize( size )
    self.size = size
    self.width, self.height = PREFAB_SIZES[self.size].WIDTH, PREFAB_SIZES[self.size].HEIGHT
    self.grid = createGrid( self.width, self.height )
end

function PrefabCanvas:toggleObjects()
    self.hideObjects = not self.hideObjects
end

return PrefabCanvas
