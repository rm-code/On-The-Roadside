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

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapPainter = Class( 'MapPainter' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MAX_SPRITES = 16384 -- Enough sprites for a 128*128 map.

local FACTIONS = require( 'src.constants.FACTIONS' )
local COLORS = {
    [FACTIONS.ALLIED] = {
        ACTIVE   = 'allied_active',
        INACTIVE = 'allied_inactive'
    },
    [FACTIONS.ENEMY] = {
        ACTIVE   = 'enemy_active',
        INACTIVE = 'enemy_inactive'
    },
    [FACTIONS.NEUTRAL] = {
        ACTIVE   = 'neutral_active',
        INACTIVE = 'neutral_inactive'
    },
}

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Adds an empty sprite for each tile in the map to the spritebatch, gives
-- each tile a unique identifier and sets it to dirty for the first update.
-- @tparam Map         map         The map to draw.
-- @tparam SpriteBatch spritebatch The spritebatch to initialize.
--
local function initSpritebatch( map, spritebatch )
    local tw, th = TexturePacks.getTileDimensions()
    map:iterate( function( tile, x, y )
        local id = spritebatch:add( TexturePacks.getSprite( 'tile_empty' ), x * tw, y * th )
        tile:setSpriteID( id )
        tile:setDirty( true )
    end)
    Log.debug( string.format( 'Initialised %d tiles.', spritebatch:getCount() ), 'MapPainter' )
end

---
-- Selects a color which to use when a tile is drawn based on its contents.
-- @tparam  Tile      tile      The tile to choose a color for.
-- @tparam  Faction   faction   The faction to draw for.
-- @treturn table               A table containing RGBA values.
--
local function selectTileColor( tile, faction )
    -- If there is a faction we check which tiles are explored and which tiles
    -- are currently seen.
    if faction then
        -- Hide unexplored tiles.
        if not tile:isExplored( faction:getType() ) then
            return TexturePacks.getColor( 'tile_unexplored' )
        end

        -- Dim tiles hidden from the player.
        if not faction:canSee( tile ) then
            return TexturePacks.getColor( 'tile_unseen' )
        end

        -- Highlight activate character.
        if tile:getCharacter() == faction:getCurrentCharacter() then
            return TexturePacks.getColor( COLORS[tile:getCharacter():getFaction():getType()].ACTIVE )
        end
    end

    if tile:isOccupied() then
        return TexturePacks.getColor( COLORS[tile:getCharacter():getFaction():getType()].INACTIVE )
    end

    if not tile:getInventory():isEmpty() then
        return TexturePacks.getColor( 'items' )
    end

    if tile:hasWorldObject() then
        return TexturePacks.getColor( tile:getWorldObject():getID() )
    end

    return TexturePacks.getColor( tile:getID() )
end

---
-- Selects the tile for drawing a tile occupied by a character.
-- @tparam  Tile tile The tile to pick a sprite for.
-- @treturn Quad      A quad pointing to the sprite on the active tileset.
--
local function selectCharacterTile( tile )
    local character = tile:getCharacter()
    return TexturePacks.getSprite( character:getBody():getID(), character:getStance() )
end

---
-- Selects the tile to use for drawing a worldobject.
-- @tparam  WorldObject worldObject The worldobject to pick a sprite for.
-- @treturn Quad                    A quad pointing to the sprite on the active tileset.
--
local function selectWorldObjectSprite( worldObject )
    if worldObject:isOpenable() then
        if worldObject:isPassable() then
            return TexturePacks.getSprite( worldObject:getID(), 'open' )
        else
            return TexturePacks.getSprite( worldObject:getID(), 'closed' )
        end
    end
    return TexturePacks.getSprite( worldObject:getID() )
end

---
-- Selects a sprite from the tileset based on the tile and its contents.
-- @tparam  Tile    tile    The tile to choose a sprite for.
-- @tparam  Faction faction The faction to draw for.
-- @treturn Quad            A quad pointing to a sprite on the tileset.
--
local function selectTileSprite( tile, faction )
    if tile:isOccupied() and faction and faction:canSee( tile ) then
        return selectCharacterTile( tile )
    end

    if not tile:getInventory():isEmpty() then
        return TexturePacks.getSprite( 'items' )
    end

    if tile:hasWorldObject() then
        return selectWorldObjectSprite( tile:getWorldObject() )
    end

    return TexturePacks.getSprite( tile:getID() )
end

---
-- Updates the spritebatch by going through every tile in the map. Only
-- tiles which have been marked as dirty will be sent to the spritebatch.
-- @tparam SpriteBatch spritebatch The spritebatch to update.
-- @tparam Map         map         The map to draw.
-- @tparam Faction     faction     The player's faction.
--
local function updateSpritebatch( spritebatch, map, faction )
    local tw, th = TexturePacks.getTileDimensions()
    map:iterate( function( tile, x, y )
        if tile:isDirty() then
            spritebatch:setColor( selectTileColor( tile, faction ))
            spritebatch:set( tile:getSpriteID(), selectTileSprite( tile, faction ), x * tw, y * th )
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

    TexturePacks.setBackgroundColor()
    self.spritebatch = love.graphics.newSpriteBatch( TexturePacks.getTileset():getSpritesheet(), MAX_SPRITES, 'dynamic' )
    initSpritebatch( self.map, self.spritebatch )
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
    updateSpritebatch( self.spritebatch, self.map, self.faction )
end

---
-- Sets the faction which is used for checking which parts of the map are visible
-- and explored.
-- @tparam Faction faction The faction to use.
--
function MapPainter:setActiveFaction( faction )
    self.faction = faction
end

return MapPainter
