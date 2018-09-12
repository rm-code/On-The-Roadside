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

-- TODO replace hardcoded colors
function LayoutBrush:draw()
    local tw, th = TexturePacks.getTileDimensions()
    if self.mode == 'draw' then
        love.graphics.setColor( 1.0, 0, 1.0, 0.4 )
        love.graphics.rectangle( 'line', self.x * tw, self.y * th, self.template.PARCEL_WIDTH * tw, self.template.PARCEL_HEIGHT * th )
    else
        love.graphics.setColor( 0.8, 0, 0, 0.4 )
        love.graphics.rectangle( 'fill', self.x * tw, self.y * th, tw, th )
    end
    TexturePacks.resetColor()
end

function LayoutBrush:use( canvas )
    local type = 'prefab'

    if self.template.TYPE == 'SPAWNS_FRIENDLY' or self.template.TYPE == 'SPAWNS_NEUTRAL' or self.template.TYPE == 'SPAWNS_ENEMY' then
        type = 'spawns'
    end

    if self.mode == 'draw' then
        canvas:place( self.x, self.y, type, self.template )
    elseif self.mode == 'erase' then
        canvas:erase( self.x, self.y, type )
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
