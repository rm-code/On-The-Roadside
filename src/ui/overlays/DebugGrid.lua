---
-- Draws a grid overlay based on the tile size of the texturepack.
-- This can be used to check proper alignment of tiles.
-- @module DebugGrid
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local DebugGrid = {}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function mod( a, b )
    return a - math.floor( a / b ) * b
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function DebugGrid.draw()
    local sw, sh = love.graphics.getDimensions()

    local tileWidth, tileHeight = TexturePacks.getTileDimensions()
    local glyphWidth, glyphHeight = TexturePacks.getGlyphDimensions()

    for x = 0, sw - 1 do
        for y = 0, sh - 1 do
            if mod( x, tileWidth ) == 0 and mod( y, tileHeight ) == 0 then
                love.graphics.setColor( 100, 100, 100, 80 )
                love.graphics.rectangle( 'line', x, y, tileWidth, tileHeight )
            end

            if mod( x, glyphWidth ) == 0 and mod( y, glyphHeight ) == 0 then
                love.graphics.setColor( 100, 100, 100, 60 )
                love.graphics.rectangle( 'line', x, y, glyphWidth, glyphHeight )
            end
        end
    end

    love.graphics.setColor( 255, 255, 255, 255 )
end


return DebugGrid
