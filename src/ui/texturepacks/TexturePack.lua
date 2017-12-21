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
-- Constructor
-- ------------------------------------------------

function TexturePack:initialize( path, source, spriteInfos, colorInfos )
    self.name = source.name

    -- Generate font.
    local f = source.font
    self.font = Font( path .. f.source, f.glyphs.source, f.glyphs.width, f.glyphs.height )
    self.glyphWidth, self.glyphHeight = f.glyphs.width, f.glyphs.height

    -- Generate tileset.
    local t = source.tileset
    self.tileset = Tileset( path .. t.source, spriteInfos, t.tiles.width, t.tiles.height )

    self.colors = colorInfos
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function self:getName()
    return self.name
end

function self:getFont()
    return self.font
end

function self:getGlyphDimensions()
    return self.glyphWidth, self.glyphHeight
end

function self:getTileset()
    return self.tileset
end

function self:getColor( id )
    return self.colors[id]
end

return TexturePack
