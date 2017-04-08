---
-- @module TexturePack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object  = require( 'src.Object' )
local Font    = require( 'src.ui.texturepacks.Font' )
local Tileset = require( 'src.ui.texturepacks.Tileset' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TexturePack = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function TexturePack.new()
    local self = Object.new():addInstance( 'TexturePack' )

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local name
    local font
    local tileset
    local colors

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( path, source, spriteInfos, colorInfos )
        name = source.name

        -- Generate font.
        local f = source.font
        font = Font.new( path .. f.source, f.glyphs.source, f.glyphs.width, f.glyphs.height )

        -- Generate tileset.
        local t = source.tileset
        tileset = Tileset.new( path .. t.source, spriteInfos, t.tiles.width, t.tiles.height )
        tileset:init()

        colors = colorInfos
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getName()
        return name
    end

    function self:getFont()
        return font
    end

    function self:getTileset()
        return tileset
    end

    function self:getColor( id )
        return colors[id]
    end

    return self
end

return TexturePack
