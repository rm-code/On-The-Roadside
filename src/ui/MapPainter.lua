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

local DIRECTION = require( 'src.constants.DIRECTION' )

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

local CONNECTION_BITMASK = {
    [0]  = 'default',

    -- Straight connections-
    [1]  = 'vertical', -- North
    [4]  = 'vertical', -- South
    [5]  = 'vertical', -- North South
    [2]  = 'horizontal', -- East
    [8]  = 'horizontal', -- West
    [10] = 'horizontal', -- East West

    -- Corners.
    [3]  = 'ne',
    [9]  = 'nw',
    [6]  = 'se',
    [12] = 'sw',

    -- T Intersection
    [7]  = 'nes',
    [11] = 'new',
    [13] = 'nws',
    [14] = 'sew',

    -- + Intersection
    [15] = 'news',
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
    map:iterate( function( x, y, tile, _ )
        local id = spritebatch:add( TexturePacks.getSprite( 'tile_empty' ), x * tw, y * th )
        tile:setSpriteID( id )
        tile:setDirty( true )
    end)
    Log.debug( string.format( 'Initialised %d tiles.', spritebatch:getCount() ), 'MapPainter' )
end

---
-- Selects a color which to use when a tile is drawn based on its contents.
-- @tparam  Tile        tile        The tile to choose a color for.
-- @tparam  WorldObject worldObject The worldobject to choose a color for.
-- @tparam  Faction     faction     The faction to draw for.
-- @treturn table                   A table containing RGBA values.
--
local function selectTileColor( tile, worldObject, faction )
    -- If there is a faction we check which tiles are currently seen and highlight
    -- the active character.
    if faction then
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
        local items = tile:getInventory():getItems()
        return TexturePacks.getColor( items[1]:getID() )
    end

    if worldObject then
        return TexturePacks.getColor( worldObject:getID() )
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
    return TexturePacks.getSprite( character:getCreatureClass(), character:getStance() )
end

---
-- Checks wether there is an adjacent world object with a group that matches the
-- connections of the original world object.
-- @tparam  table  connections The connections table containing the groups the world object connects to.
-- @tparam  Tile   neighbour   The neighbouring tile to check for a matching world object.
-- @tparam  number value       The value to return in case the world object matches.
-- @treturn number             The value indicating a match (0 if the world object doesn't match).
--
local function checkConnection( connections, neighbour, value )
    if neighbour and neighbour:hasWorldObject() then
        local group = neighbour:getWorldObject():getGroup()
        if group then
            for i = 1, #connections do
                if connections[i] == group then
                    return value
                end
            end
        end
    end
    return 0
end

---
-- Selects the tile to use for drawing a worldobject.
-- @tparam  WorldObject worldObject The worldobject to pick a sprite for.
-- @treturn Quad                    A quad pointing to the sprite on the active tileset.
--
local function selectWorldObjectSprite( worldObject, tile )
    if worldObject:isOpenable() then
        if worldObject:isPassable() then
            return TexturePacks.getSprite( worldObject:getID(), 'open' )
        else
            return TexturePacks.getSprite( worldObject:getID(), 'closed' )
        end
    end

    -- Check if the world object sprite connects to adjacent sprites.
    local connections = worldObject:getConnections()
    if connections then
        -- FIXME
        return TexturePacks.getSprite( worldObject:getID(), CONNECTION_BITMASK[0] )
    end

    return TexturePacks.getSprite( worldObject:getID() )
end

---
-- Selects a sprite from the tileset based on the contents of a tile.
-- @tparam  Tile        tile        The tile to choose a sprite for.
-- @tparam  WorldObject worldObject The worldObject to choose a sprite for.
-- @tparam  Faction     faction     The faction to draw for.
-- @treturn Quad                    A quad pointing to a sprite on the tileset.
--
local function selectTileSprite( tile, worldObject, faction )
    if tile:isOccupied() and faction and faction:canSee( tile ) then
        return selectCharacterTile( tile )
    end

    if not tile:getInventory():isEmpty() then
        local items = tile:getInventory():getItems()
        return TexturePacks.getSprite( items[1]:getID() )
    end

    if worldObject then
        return selectWorldObjectSprite( worldObject, tile )
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
    map:iterate( function( x, y, tile, worldObject )
        if tile:isDirty() then
            spritebatch:setColor( selectTileColor( tile, worldObject, faction ))
            spritebatch:set( tile:getSpriteID(), selectTileSprite( tile, worldObject, faction ), x * tw, y * th )
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
-- Sets the faction which is used for checking which parts of the map are visible.
-- @tparam Faction faction The faction to use.
--
function MapPainter:setActiveFaction( faction )
    self.faction = faction
end

return MapPainter
