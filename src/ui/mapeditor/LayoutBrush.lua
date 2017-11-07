---
-- @module LayoutBrush
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local LayoutBrush = Class( 'LayoutBrush' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function LayoutBrush:initialize( template )
    self.template = template
    self.mode = 'draw'
    self.x, self.y = 0, 0
end

function LayoutBrush:draw()
    local tw, th = TexturePacks.getTileDimensions()
    if self.mode == 'draw' then
        love.graphics.setColor( 255, 0, 255, 100 )
        love.graphics.rectangle( 'line', self.x * tw, self.y * th, self.template.PARCEL_WIDTH * tw, self.template.PARCEL_HEIGHT * th )
    else
        love.graphics.setColor( 200, 0, 0, 100 )
        love.graphics.rectangle( 'fill', self.x * tw, self.y * th, tw, th )
    end
    TexturePacks.resetColor()
end

function LayoutBrush:use( canvas )
    if self.mode == 'draw' then
        canvas:place( self.x, self.y, self.template )
    elseif self.mode == 'erase' then
        canvas:erase( self.x, self.y )
    end
end

function LayoutBrush:setPosition( x, y )
    self.x, self.y = x, y
end

function LayoutBrush:setTemplate( template )
    self.template = template
end

function LayoutBrush:setMode( mode )
    self.mode = mode
end

return LayoutBrush
