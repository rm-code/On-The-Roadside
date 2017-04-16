---
-- @module UICopyrightFooter
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UICopyrightFooter = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local VERSION_STRING = string.format( 'PRE-ALPHA Version: %s ', getVersion() )
local COPYRIGHT_STRING = ' © Robert Machmer, 2016-2017. All rights reserved.'

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UICopyrightFooter.new()
    local self = Object.new():addInstance( 'UICopyrightFooter' )

    function self:draw()
        local font = TexturePacks.getFont()
        local sw, sh = love.graphics.getDimensions()
        TexturePacks.setColor( 'ui_text_dim' )
        love.graphics.print( VERSION_STRING, sw - font:measureWidth( VERSION_STRING ), sh - font:getGlyphHeight() )
        love.graphics.print( COPYRIGHT_STRING, 0, sh - font:getGlyphHeight() )
        TexturePacks.resetColor()
    end

    return self
end

return UICopyrightFooter
