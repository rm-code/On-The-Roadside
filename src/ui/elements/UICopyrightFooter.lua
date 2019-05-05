---
-- @module UICopyrightFooter
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UICopyrightFooter = Class( 'UICopyrightFooter' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local VERSION_STRING = string.format( 'PRE-ALPHA Version: %s ', getVersion() )
local COPYRIGHT_STRING = 'Copyright © 2016 - %s Robert Machmer'

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UICopyrightFooter:initialize()
    self.copyright = string.format( COPYRIGHT_STRING, os.date( "%Y", os.time() ))
end

function UICopyrightFooter:draw()
    local font = TexturePacks.getFont()
    local tw, th = TexturePacks.getTileDimensions()
    local sw, sh = GridHelper.getScreenGridDimensions()

    TexturePacks.setColor( 'ui_text_dim' )
    love.graphics.print( VERSION_STRING, sw*tw - font:measureWidth( VERSION_STRING ), sh*th - font:getGlyphHeight() )
    love.graphics.print( self.copyright, tw, sh*th - font:getGlyphHeight() )
    TexturePacks.resetColor()
end

return UICopyrightFooter
