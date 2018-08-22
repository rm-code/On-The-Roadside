---
-- @module Grid
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Grid = Class( 'Grid' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Grid:initialize( width, height )
    local tw, th = TexturePacks.getTileDimensions()

    self.canvas = love.graphics.newCanvas( width * tw , height * th )
    self.canvas:renderTo( function()
        TexturePacks.resetColor()
        for x = 0, width do
            love.graphics.line( x * tw, 0, x * tw, height * th )
        end
        for y = 0, height do
            love.graphics.line( 0, y * tw, width * tw, y * tw )
        end
        TexturePacks.resetColor()
    end)
end

function Grid:draw( x, y )
    TexturePacks.setColor( 'ingame_editor_grid_lines' )
    love.graphics.draw( self.canvas, x, y )
end

return Grid
