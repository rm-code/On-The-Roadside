---
-- The Font class creates an ImageFont based on the information provided by
-- a texture pack.
-- @module Font
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Font = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new instance of the Font class.
-- @tparam  string source  The path to load the imagefont file from.
-- @tparam  string glyphs  The glyph definition.
-- @tparam  number gwidth  The width of one glyph.
-- @tparam  number gheight The height of one glpyh.
-- @treturn Font           The new Font instance.
--
function Font.new( source, glyphs, gwidth, gheight )
    local self = Object.new():addInstance( 'Font' )

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local font = love.graphics.newImageFont( source, glyphs )

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Sets the current font so that it is used when drawing text.
    --
    function self:use()
        love.graphics.setFont( font )
    end

    ---
    -- Measures the width of a string in pixels.
    -- @tparam  string str The string to measure.
    -- @treturn number     The width of the string in pixels.
    --
    function self:measureWidth( str )
        return font:getWidth( str )
    end

    ---
    -- Aligns a string while taking the font's grid into account.
    -- @tparam  string alignMode Determines how the font is aligned (center, left or right).
    -- @tparam  string str       The text to align.
    -- @tparam  number width     The width of the area in which to align the string.
    -- @treturn number           The position at which to draw the string.
    --
    function self:align( alignMode, str, width )
        if alignMode == 'center' then
            local offset = width * 0.5 - font:getWidth( str ) * 0.5
            return math.floor( offset / gwidth ) * gwidth
        elseif alignMode == 'left' then
            return 0
        elseif alignMode == 'right' then
            local offset = width - font:getWidth( str )
            return math.floor( offset / gwidth ) * gwidth
        end
        error( string.format( 'Invalid align mode "%s". Use "center", "left" or "right" instead.' ), alignMode )
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:get()
        return font
    end

    function self:getGlyphWidth()
        return gwidth
    end

    function self:getGlyphHeight()
        return gheight
    end

    return self
end

return Font
