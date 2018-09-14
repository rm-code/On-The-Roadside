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
-- Selects a color which to use when a tile is drawn based on its contents.
-- @tparam  Tile        tile                The tile to choose a color for.
-- @tparam  WorldObject worldObject         The worldobject to choose a color for.
-- @tparam  boolean     worldObjectsVisible Wether or not to hide world objects.
-- @tparam  Character   character           A character to choose a color for.
-- @tparam  Faction     faction             The faction to draw for.
-- @treturn table                           A table containing RGBA values.
--
local function selectTileColor( tile, worldObject, worldObjectsVisible, character, faction )
    -- If there is a faction we check which tiles are currently seen and highlight
    -- the active character.
    if faction then
        -- Dim tiles hidden from the player.
        if not tile:isSeenBy( faction:getType() ) then
            return TexturePacks.getColor( 'tile_unseen' )
        end

        -- Highlight activated character.
        if character == faction:getCurrentCharacter() then
            return TexturePacks.getColor( COLORS[character:getFaction():getType()].ACTIVE )
        end
    end

    if character then
        return TexturePacks.getColor( COLORS[character:getFaction():getType()].INACTIVE )
    end

    if not tile:getInventory():isEmpty() then
        local items = tile:getInventory():getItems()
        return TexturePacks.getColor( items[1]:getID() )
    end

    if worldObjectsVisible and worldObject then
        return TexturePacks.getColor( worldObject:getID() )
    end

    return TexturePacks.getColor( tile:getID() )
end

---
-- Selects the sprite for drawing a character.
-- @tparam  Character character The character to choose a sprite for.
-- @treturn Quad                A quad pointing to the sprite on the active tileset.
--
local function selectCharacterTile( character )
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
    if neighbour then
        local group = neighbour:getGroup()
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
-- Selects the sprite to use for drawing a worldObject.
-- @tparam  WorldObject worldObject The worldObject to pick a sprite for.
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

    -- Check if the world object sprite connects to adjacent sprites.
    local connections = worldObject:getConnections()
    if connections then
        local neighbours = worldObject:getNeighbours()
        local result = checkConnection( connections, neighbours[DIRECTION.NORTH], 1 ) +
                       checkConnection( connections, neighbours[DIRECTION.EAST],  2 ) +
                       checkConnection( connections, neighbours[DIRECTION.SOUTH], 4 ) +
                       checkConnection( connections, neighbours[DIRECTION.WEST],  8 )
        return TexturePacks.getSprite( worldObject:getID(), CONNECTION_BITMASK[result] )
    end

    return TexturePacks.getSprite( worldObject:getID() )
end

---
-- Selects a sprite from the tileset based on the contents of a tile.
-- @tparam  Tile        tile                The tile to choose a sprite for.
-- @tparam  WorldObject worldObject         The worldObject to choose a sprite for.
-- @tparam  boolean     worldObjectsVisible Wether or not to hide world objects.
-- @tparam  Character   character           A character to choose a sprite for.
-- @tparam  Faction     faction             The faction to draw for.
-- @treturn Quad                            A quad pointing to a sprite on the tileset.
--
local function selectTileSprite( tile, worldObject, worldObjectsVisible, character, faction )
    if character and tile:isSeenBy( faction:getType() ) then
        return selectCharacterTile( character )
    end

    if not tile:getInventory():isEmpty() then
        local items = tile:getInventory():getItems()
        return TexturePacks.getSprite( items[1]:getID() )
    end

    if worldObjectsVisible and worldObject then
        return selectWorldObjectSprite( worldObject )
    end

    return TexturePacks.getSprite( tile:getID() )
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
            spritebatch:setColor( selectTileColor( tile, worldObject, worldObjectsVisible, character, faction ))
            spritebatch:set( spriteIndex[x][y], selectTileSprite( tile, worldObject, worldObjectsVisible, character, faction ), x * tw, y * th )
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
