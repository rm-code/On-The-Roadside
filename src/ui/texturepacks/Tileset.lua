---
-- The Tileset class creates an Tileset based on the information provided by
-- a texture pack.
-- @module Tileset
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Tileset = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new instance of the Tileset class.
-- @tparam  string source  The path to load the spritesheet file from.
-- @tparam  table  infos   A table mapping tile and object IDs to sprite information.
-- @tparam  number twidth  The width of one tile.
-- @tparam  number theight The height of one tile.
-- @treturn Font           The new Tileset instance.
--
function Tileset.new( source, infos, twidth, theight )
    local self = Object.new():addInstance( 'Tileset' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local spritesheet
    local sprites

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Initializes the tileset.
    --
    function self:init()
        spritesheet = love.graphics.newImage( source )
        sprites = {}

        for x = 1, spritesheet:getWidth() / twidth do
            for y = 1, spritesheet:getHeight() / theight do
                local qx, qy = (y-1) * twidth, (x-1) * theight
                sprites[#sprites + 1] = love.graphics.newQuad( qx, qy, twidth, theight, spritesheet:getDimensions() )
            end
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns a quad which maps to a sprite on the tileset based on the id.
    -- By default an id points to a number which in turn points to a quad in
    -- the tileset.
    -- If the subid parameter is not nil the id should point to a table which
    -- contains a list of subids which point to quad numbers. This can be used
    -- to have different sprites based on the state of an object or to draw
    -- connected tiles.
    -- @tparam string id    The id to search for in the infos table.
    -- @tparam string subid The subid to search for in the infos table (optional)
    --
    function self:getSprite( id, subid )
        local definition = infos[id]
        if not definition then
            error( string.format( 'Can not find a sprite definition for [%s].', id ))
        end

        if subid then
            if type( definition ) ~= 'table' then
                error( string.format( 'Tried to get a sub-sprite [%s] from a non-table defintion [%s].', subid, id ))
            end

            local index = definition[subid]
            if not index then
                error( string.format( 'Can not find a sub-sprite definition for [%s][%s].', id, subid ))
            end

            return sprites[index]
        end

        return sprites[definition]
    end

    function self:getSpritesheet()
        return spritesheet
    end

    function self:getTileDimensions()
        return twidth, theight
    end

    return self
end

return Tileset
