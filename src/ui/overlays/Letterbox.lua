---
-- Draws a padding to the bottom and the right side of the screen to hide any
-- pixels which wouldn't fit on the screen grid.
--
-- @module Letterbox
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' );
local GridHelper = require( 'src.util.GridHelper' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Letterbox = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Letterbox.new()
    local self = Object.new():addInstance( 'Letterbox' )

    local sw, sh
    local w, h

    local function calculateDimensions( nsw, nsh )
        local gw, gh = GridHelper.getScreenGridDimensions()
        local tw, th = TexturePacks.getTileDimensions()

        sw, sh = nsw, nsh

        w = love.graphics.getWidth() - (gw * tw)
        h = love.graphics.getHeight() - (gh * th)
    end

    function self:init()
        calculateDimensions( love.graphics.getDimensions() )
    end

    function self:draw()
        TexturePacks.setColor( 'sys_background' )
        love.graphics.rectangle( 'fill', 0, sh-h, sw, h )
        love.graphics.rectangle( 'fill', sw-w, 0, w, sh )
        TexturePacks.resetColor()
    end

    function self:resize( nsw, nsh )
        calculateDimensions( nsw, nsh )
    end

    return self
end

return Letterbox
