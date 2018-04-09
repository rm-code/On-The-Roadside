---
-- @module LayoutCanvas
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Util = require( 'src.util.Util' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local LayoutCanvas = Class( 'LayoutCanvas' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MIN_MAP_WIDTH  =  6
local MIN_MAP_HEIGHT =  6

local MAX_MAP_WIDTH  = 16
local MAX_MAP_HEIGHT = 16

local COLORS = {
    SPAWNS_FRIENDLY = 'parcel_spawns_friendly',
    SPAWNS_NEUTRAL = 'parcel_spawns_neutral',
    SPAWNS_ENEMY = 'parcel_spawns_enemy',
    FOLIAGE = 'parcel_foliage',
    ROAD = 'parcel_road',
    XS = 'parcel_xs',
    S  = 'parcel_s',
    M  = 'parcel_m',
    L  = 'parcel_l',
    XL = 'parcel_xl'
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function LayoutCanvas:initialize()
    self.grid = {
        mapwidth = MIN_MAP_WIDTH,
        mapheight = MIN_MAP_HEIGHT,
        prefabs = {},
        spawns = {}
    }
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Draws the layout canvas.
--
function LayoutCanvas:draw()
    local tw, th = TexturePacks.getTileDimensions()

    -- Draws a translucent grid.
    TexturePacks.setColor( 'sys_debug_grid' )

    for x = 1, self.grid.mapwidth do
        for y = 1, self.grid.mapheight do
            love.graphics.rectangle( 'line', x * tw, y * th, tw, th )
        end
    end

    -- Draws the layouts with custom colors.
    for type, templates in pairs( self.grid.prefabs ) do
        for _, template in ipairs( templates ) do
            TexturePacks.setColor( COLORS[type] )
            love.graphics.rectangle( 'fill', template.x * tw, template.y * th, template.w * tw, template.h * th )
            TexturePacks.resetColor()
        end
    end

    -- Draws the spawns with custom colors.
    for type, templates in pairs( self.grid.spawns ) do
        for _, template in ipairs( templates ) do
            TexturePacks.setColor( COLORS[type] )
            love.graphics.rectangle( 'line', template.x * tw, template.y * th, template.w * tw, template.h * th )
            TexturePacks.resetColor()
        end
    end

    TexturePacks.resetColor()
end

---
-- Places a new layout at a specific positon on the grid.
-- @tparam number x         The coordinate along the x-axis.
-- @tparam number y         The coordinate along the y-axis.
-- @tparam string type      The type of layout (prefabs or spawns).
-- @tparam table  mtemplate The layout to place.
--
function LayoutCanvas:place( x, y, type, ntemplate )
    -- Check if the coordinate is inside of our canvas.
    if x < 1 or x > self.grid.mapwidth or y < 1 or y > self.grid.mapheight then
        return
    end

    -- Target prefabs unless we have spawns.
    local target = type == 'prefab' and self.grid.prefabs or self.grid.spawns

    -- Check if there are any other templates at this position.
    -- TODO fix for multi-parcel prefabs.
    -- TODO fix if layout is bigger than canvas
    for _, templates in pairs( target ) do
        for _, template in ipairs( templates ) do
            if x >= template.x and x < template.x + template.w and y >= template.y and y < template.y + template.h then
                return
            end
        end
    end

    target[ntemplate.TYPE] = target[ntemplate.TYPE] or {}
    table.insert( target[ntemplate.TYPE], { x = x, y = y, w = ntemplate.PARCEL_WIDTH, h = ntemplate.PARCEL_HEIGHT })
end

---
-- Erases all layouts that overlap a certain position on the grid.
-- @tparam number x The coordinate along the x-axis.
-- @tparam number y The coordinate along the y-axis.
-- @tparam string type      The type of layout (prefabs or spawns).
--
function LayoutCanvas:erase( x, y, type )
    -- Check if the coordinate is inside of our canvas.
    if x < 1 or x > self.grid.mapwidth or y < 1 or y > self.grid.mapheight then
        return
    end

    -- Target prefabs unless we have spawns.
    local target = type == 'prefab' and self.grid.prefabs or self.grid.spawns

    -- Remove layouts below cursor.
    for _, templates in pairs( target ) do
        for i = #templates, 1, -1 do
            local template = templates[i]
            if x >= template.x and x < template.x + template.w and y >= template.y and y < template.y + template.h then
                table.remove( templates, i )
            end
        end
    end
end

---
-- Resizes the canvas, but makes sure it doesn't break the minimum and maximum
-- size values.
-- @tparam number dw The value to add horizontally.
-- @tparam number dh The value to add vertically.
--
function LayoutCanvas:resize( dw, dh )
    self.grid.mapwidth  = Util.clamp( MIN_MAP_WIDTH,  self.grid.mapwidth  + dw, MAX_MAP_WIDTH  )
    self.grid.mapheight = Util.clamp( MIN_MAP_HEIGHT, self.grid.mapheight + dh, MAX_MAP_HEIGHT )
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function LayoutCanvas:getWidth()
    return self.grid.mapwidth
end

function LayoutCanvas:getHeight()
    return self.grid.mapheight
end

function LayoutCanvas:getGrid()
    return self.grid
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function LayoutCanvas:setGrid( grid )
    self.grid = grid
end

return LayoutCanvas
