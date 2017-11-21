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

local MIN_MAP_WIDTH  =  3
local MIN_MAP_HEIGHT =  3

local MAX_MAP_WIDTH  = 16
local MAX_MAP_HEIGHT = 16

local COLORS = {
    FOLIAGE = 'parcel_foliage',
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
        prefabs = {}
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
    love.graphics.setColor( 100, 100, 100, 100 )
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

    love.graphics.setColor( 255, 255, 255, 255 )
end

---
-- Places a new layout at a specific positon on the grid.
-- @tparam number x         The coordinate along the x-axis.
-- @tparam number y         The coordinate along the y-axis.
-- @tparam table  mtemplate The layout to place.
--
function LayoutCanvas:place( x, y, ntemplate )
    -- Check if the coordinate is inside of our canvas.
    if x < 1 or x > self.grid.mapwidth or y < 1 or y > self.grid.mapheight then
        return
    end

    -- Check if there are any other templates at this position.
    -- TODO fix for multi-parcel prefabs.
    -- TODO fix if layout is bigger than canvas
    for _, templates in pairs( self.grid.prefabs ) do
        for _, template in ipairs( templates ) do
            if x >= template.x and x < template.x + template.w and y >= template.y and y < template.y + template.h then
                return
            end
        end
    end

    local target = self.grid.prefabs
    target[ntemplate.TYPE] = target[ntemplate.TYPE] or {}
    table.insert( target[ntemplate.TYPE], { x = x, y = y, w = ntemplate.PARCEL_WIDTH, h = ntemplate.PARCEL_HEIGHT })
end

---
-- Erases all layouts that overlap a certain position on the grid.
-- @tparam number x The coordinate along the x-axis.
-- @tparam number y The coordinate along the y-axis.
--
function LayoutCanvas:erase( x, y )
    -- Check if the coordinate is inside of our canvas.
    if x < 1 or x > self.grid.mapwidth or y < 1 or y > self.grid.mapheight then
        return
    end

    -- Remove layouts below cursor.
    for _, templates in pairs( self.grid.prefabs ) do
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