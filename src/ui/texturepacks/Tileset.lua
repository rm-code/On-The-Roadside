---
-- The Tileset class creates an Tileset based on the information provided by
-- a texture pack.
-- @module Tileset
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Tileset = Class( 'Tileset' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new instance of the Tileset class.
-- @tparam  string source The path to load the spritesheet file from.
-- @tparam  table  infos  A table mapping tile and object IDs to sprite information.
-- @tparam  number tw     The width of one tile.
-- @tparam  number th     The height of one tile.
-- @treturn Font          The new Tileset instance.
--
function Tileset:initialize( source, infos, tw, th )
    self.source = source
    self.infos = infos
    self.tileWidth = tw
    self.tileHeight = th

    self.spritesheet = love.graphics.newImage( source )
    self.sprites = {}

    for x = 1, self.spritesheet:getWidth() / tw do
        for y = 1, self.spritesheet:getHeight() / th do
            local qx, qy = (y-1) * tw, (x-1) * th
            self.sprites[#self.sprites + 1] = love.graphics.newQuad( qx, qy, tw, th, self.spritesheet:getDimensions() )
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
function Tileset:getSprite( id, subid )
    local definition = self.infos[id]
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

        return self.sprites[index]
    end

    return self.sprites[definition]
end

function Tileset:getSpritesheet()
    return self.spritesheet
end

function Tileset:getTileDimensions()
    return self.tileWidth, self.tileHeight
end

return Tileset
