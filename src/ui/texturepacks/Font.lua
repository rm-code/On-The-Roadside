---
-- The Font class creates an ImageFont based on the information provided by
-- a texture pack.
-- @module Font
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Font = Class( 'Font' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new instance of the Font class.
-- @tparam  string source The path to load the imagefont file from.
-- @tparam  string glyphs The glyph definition.
-- @tparam  number gw     The width of one glyph.
-- @tparam  number gh     The height of one glpyh.
-- @treturn Font          The new Font instance.
--
function Font:initialize( source, glyphs, gw, gh )
    self.font = love.graphics.newImageFont( source, glyphs )
    self.glyphWidth = gw
    self.glyphHeight = gh
end

---
-- Sets the current font so that it is used when drawing text.
--
function Font:use()
    love.graphics.setFont( self.font )
end

---
-- Measures the width of a string in pixels.
-- @tparam  string str The string to measure.
-- @treturn number     The width of the string in pixels.
--
function Font:measureWidth( str )
    return self.font:getWidth( str )
end

---
-- Aligns a string while taking the font's grid into account.
-- @tparam  string alignMode Determines how the font is aligned (center, left or right).
-- @tparam  string str       The text to align.
-- @tparam  number width     The width of the area in which to align the string.
-- @treturn number           The position at which to draw the string.
--
function Font:align( alignMode, str, width )
    if alignMode == 'center' then
        local offset = width * 0.5 - self.font:getWidth( str ) * 0.5
        return math.floor( offset / self.glyphWidth ) * self.glyphWidth
    elseif alignMode == 'left' then
        return 0
    elseif alignMode == 'right' then
        local offset = width - self.font:getWidth( str )
        return math.floor( offset / self.glyphWidth ) * self.glyphWidth
    end
    error( string.format( 'Invalid align mode "%s". Use "center", "left" or "right" instead.' ), alignMode )
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function Font:get()
    return self.font
end

function Font:getGlyphWidth()
    return self.glyphWidth
end

function Font:getGlyphHeight()
    return self.glyphHeight
end

return Font
