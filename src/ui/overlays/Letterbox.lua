---
-- Draws a padding to the bottom and the right side of the screen to hide any
-- pixels which wouldn't fit on the screen grid.
--
-- @module Letterbox
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local GridHelper = require( 'src.util.GridHelper' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Letterbox = Class( 'Letterbox' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Letterbox:draw()
    local sw, sh = love.graphics.getDimensions()
    local ow, oh = GridHelper.getScreenOverflow()
    TexturePacks.setColor( 'sys_background' )
    love.graphics.rectangle( 'fill',     0, sh-oh, sw, oh )
    love.graphics.rectangle( 'fill', sw-ow,     0, ow, sh )
    TexturePacks.resetColor()
end

return Letterbox
