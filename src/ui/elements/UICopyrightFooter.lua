---
-- @module UICopyrightFooter
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

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
        local tw, th = TexturePacks.getTileDimensions()
        local sw, sh = GridHelper.getScreenGridDimensions()

        TexturePacks.setColor( 'ui_text_dim' )
        love.graphics.print( VERSION_STRING, sw*tw - font:measureWidth( VERSION_STRING ), sh*th - font:getGlyphHeight() )
        love.graphics.print( COPYRIGHT_STRING, 0, sh*th - font:getGlyphHeight() )
        TexturePacks.resetColor()
    end

    return self
end

return UICopyrightFooter
