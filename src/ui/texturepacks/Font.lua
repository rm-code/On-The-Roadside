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
