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
-- Draws the tiles and world objects in the grid.
-- @tparam table   grid            The two-dimensional array containing the grid.
-- @tparam number  tw              The width of each grid cell in pixels.
-- @tparam number  th              The width of each grid cell in pixels.
-- @tparam boolean hideObjectLayer Wether to hide the object layer or not.
--
local function drawGrid( grid, tw, th, hideObjectLayer )
    for x = 1, #grid do
        for y = 1, #grid[x] do
            -- Draw tile layer.
            if grid[x][y].tile then
                local tileID = grid[x][y].tile.id
                TexturePacks.setColor( tileID )
                love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), TexturePacks.getSprite( tileID ), x * tw, y * tw )
            end


            -- Draw worldobject layer.
            if grid[x][y].worldObject and not hideObjectLayer then
                local template = grid[x][y].worldObject
                local worldObjectID = template.id
                TexturePacks.setColor( 'sys_background' )
                love.graphics.rectangle( 'fill', x * tw, y * th, tw, th )

                local sprite
                if template.openable then
                    sprite = TexturePacks.getSprite( worldObjectID, 'closed' )
                else
                    sprite  = TexturePacks.getSprite( worldObjectID )
                end

                TexturePacks.setColor( worldObjectID )
                love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), sprite, x * tw, y * th )
            end
        end
    end
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
    drawGrid( self.grid, tw, th, self.hideObjects )
end

function PrefabCanvas:setTile( x, y, type, content )
    if self.grid[x] and self.grid[x][y] then
        self.grid[x][y][type] = content
    end
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
