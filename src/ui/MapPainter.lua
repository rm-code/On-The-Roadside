---
-- This module takes care of drawing the game's map tiles.
-- It uses a spritebatch to optimise the drawing operation since the map
-- remains static and only needs to be updated when the state of the world
-- changes.
-- Only tiles which are marked as dirty will be updated by the MapPainter.
--
-- @module MapPainter
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Log = require( 'src.util.Log' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local TilePainter = require( 'src.ui.TilePainter' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapPainter = Class( 'MapPainter' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MAX_SPRITES = 16384 -- Enough sprites for a 128*128 map.

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Adds an empty sprite for each tile in the map to the spritebatch, gives
-- each tile a unique identifier and sets it to dirty for the first update.
-- @tparam Map         map         The map to draw.
-- @tparam SpriteBatch spritebatch The spritebatch to initialize.
-- @treturn table                  A table containing the sprite ids for each tile.
--
local function initSpritebatch( map, spritebatch )
    local tw, th = TexturePacks.getTileDimensions()
    local spriteIndex = {}

    map:iterate( function( x, y, tile, _ )
        local id = spritebatch:add( TexturePacks.getSprite( 'tile_empty' ), x * tw, y * th )
        spriteIndex[x] = spriteIndex[x] or {}
        spriteIndex[x][y] = id
        tile:setDirty( true )
    end)
    Log.info( string.format( 'Initialised %d tiles.', spritebatch:getCount() ), 'MapPainter' )

    return spriteIndex
end

---
-- Updates the spritebatch by going through every tile in the map. Only
-- tiles which have been marked as dirty will be sent to the spritebatch.
-- @tparam SpriteBatch spritebatch         The spritebatch to update.
-- @tparam table       spriteIndex         A table containing the sprite IDs for each tile.
-- @tparam Map         map                 The map to draw.
-- @tparam Faction     faction             The player's faction.
-- @tparam boolean     worldObjectsVisible Wether or not to hide world objects.
--
local function updateSpritebatch( spritebatch, spriteIndex, map, faction, worldObjectsVisible )
    local tw, th = TexturePacks.getTileDimensions()
    map:iterate( function( x, y, tile, worldObject, character )
        if tile:isDirty() then
            spritebatch:setColor( TilePainter.selectTileColor( tile, worldObject, character, worldObjectsVisible, faction ))
            spritebatch:set( spriteIndex[x][y], TilePainter.selectTileSprite( tile, worldObject, character, worldObjectsVisible, faction ), x * tw, y * th )
            tile:setDirty( false )
        end
    end)
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes the new instance of the MapPainter class.
-- @tparam Map      map      The map to draw.
--
function MapPainter:initialize( map )
    self.map = map
    self.worldObjectsVisible = true

    TexturePacks.setBackgroundColor()
    self.spritebatch = love.graphics.newSpriteBatch( TexturePacks.getTileset():getSpritesheet(), MAX_SPRITES, 'dynamic' )
    self.spriteIndex = initSpritebatch( self.map, self.spritebatch )
end

---
-- Draws the game's world.
--
function MapPainter:draw()
    love.graphics.draw( self.spritebatch, 0, 0 )
end

---
-- Updates the spritebatch for the game's world.
--
function MapPainter:update()
    updateSpritebatch( self.spritebatch, self.spriteIndex, self.map, self.faction, self.worldObjectsVisible )
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets the faction which is used for checking which parts of the map are visible.
-- @tparam Faction faction The faction to use.
--
function MapPainter:setActiveFaction( faction )
    self.faction = faction
end

---
-- Determines wether to hide or show the world object layer.
-- @tparam boolean visible Wether to show or hide the object layer.
--
function MapPainter:setWorldObjectsVisible( visible )
    self.worldObjectsVisible = visible

    self.map:iterate( function( _, _, tile, worldObject )
        if worldObject then
            tile:setDirty( true )
        end
    end)
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns wether the world object layer is currently hidden or not.
-- @tparam boolean True if it is visible, false if not.
--
function MapPainter:getWorldObjectsVisible()
    return self.worldObjectsVisible
end

return MapPainter
