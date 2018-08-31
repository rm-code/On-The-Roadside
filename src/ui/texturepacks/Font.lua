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
-- Assembles the string containing all glyphs for the ImageFont.
-- @tparam  table  charsets A sequence containing the different charset definitions.
-- @treturn string          The assembled glyph strings.
--
local function assembleGlyphs( charsets )
    local glyphs = ''
    for _, charset in ipairs( charsets ) do
        glyphs = glyphs .. charset.glyphs
    end
    return glyphs
end

---
-- Assembles the ImageData for the ImageFont.
-- @tparam  number    height   The height of the ImageFont.
-- @tparam  string    path     The path of the image files to load.
-- @tparam  table     charsets A sequence containing the different charset definitions.
-- @treturn ImageData          The assembled ImageData.
--
local function assembleImageData( height, path, charsets )
    local fontWidth = 0
    local imageDatas = {}

    -- Check how many pixels we need for the new ImageData and store the
    -- different ImageData objects.
    for _, definition in ipairs( charsets ) do
        local data = love.image.newImageData( path .. definition.source )
        fontWidth = fontWidth + data:getWidth()
        imageDatas[#imageDatas + 1] = data
    end

    -- Create the empty ImageData.
    local fontImageData = love.image.newImageData( fontWidth, height )

    -- Paste the different ImageDatas to the font's ImageData.
    local offset = 0
    for _, data in ipairs( imageDatas ) do
        fontImageData:paste( data, offset, 0, 0, 0, data:getDimensions() )
        offset = offset + data:getWidth()
    end

    return fontImageData
end

---
-- Creates a new instance of the Font class.
-- @tparam  string path The path to load the imagefont file from.
-- @tparam  table  def  The font definition.
-- @treturn Font        The new Font instance.
--
function Font:initialize( path, def )
    self.glyphWidth = def.width
    self.glyphHeight = def.height

    -- Assemble the parts of the ImageFont.
    local glyphs = assembleGlyphs( def.charsets )
    local imageData = assembleImageData( def.height, path, def.charsets )

    -- Create the ImageFont.
    self.font = love.graphics.newImageFont( imageData, glyphs )
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
