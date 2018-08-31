---
-- @module TexturePack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class   = require( 'lib.Middleclass' )
local Font    = require( 'src.ui.texturepacks.Font' )
local Tileset = require( 'src.ui.texturepacks.Tileset' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TexturePack = Class( 'TexturePack' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function TexturePack:initialize( path, source, spriteInfos, colorInfos )
    self.name = source.name

    -- Generate font.
    self.font = Font( path, source.font )
    self.glyphWidth, self.glyphHeight = source.font.width, source.font.height

    -- Generate tileset.
    local t = source.tileset
    self.tileset = Tileset( path .. t.source, spriteInfos, t.tiles.width, t.tiles.height )

    self.colors = colorInfos
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function TexturePack:getName()
    return self.name
end

function TexturePack:getFont()
    return self.font
end

function TexturePack:getGlyphDimensions()
    return self.glyphWidth, self.glyphHeight
end

function TexturePack:getTileset()
    return self.tileset
end

function TexturePack:getColor( id )
    return self.colors[id]
end

return TexturePack
