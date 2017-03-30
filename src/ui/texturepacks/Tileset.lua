---
-- The Tileset class creates an Tileset based on the information provided by
-- a texture pack.
-- @module Tileset
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )
local Log = require( 'src.util.Log' )

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
-- @tparam  number twidth  The width of one tile.
-- @tparam  number theight The height of one tile.
-- @treturn Font           The new Tileset instance.
--
function Tileset.new( source, twidth, theight )
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

    function self:getSprite( number )
        return sprites[number]
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
