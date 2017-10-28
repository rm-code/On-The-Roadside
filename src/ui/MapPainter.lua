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

local Log = require( 'src.util.Log' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapPainter = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MAX_SPRITES = 16384 -- Enough sprites for a 128*128 map.

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Generates a new instance of the MapPainter class.
--
function MapPainter.new()
    local self = {}

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local spritebatch
    local tileset
    local tw, th

    local map, factions

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Adds an empty sprite for each tile in the map to the spritebatch, gives
    -- each tile a unique identifier and sets it to dirty for the first update.
    --
    local function initSpritebatch()
        map:iterate( function( tile, x, y )
            local id = spritebatch:add( tileset:getSprite( 'tile_empty' ), x * tw, y * th )
            tile:setSpriteID( id )
            tile:setDirty( true )
        end)
        Log.debug( string.format('Initialised %d tiles.', spritebatch:getCount()), 'MapPainter' )
    end

    ---
    -- Selects a color which to use when a tile is drawn based on its contents.
    -- @tparam  Tile      tile      The tile to choose a color for.
    -- @tparam  Faction   faction   The faction to draw for.
    -- @treturn table               A table containing RGBA values.
    --
    local function selectTileColor( tile, faction )
        local character = faction:getCurrentCharacter()

        -- Hide unexplored tiles.
        if not tile:isExplored( faction:getType() ) then
            return TexturePacks.getColor( 'tile_unexplored' )
        end

        -- Dim tiles hidden from the player.
        if not faction:canSee( tile ) then
            return TexturePacks.getColor( 'tile_unseen' )
        end

        if tile:isOccupied() then
            local tchar = tile:getCharacter()
            if tchar == character then
                return TexturePacks.getColor( tchar:getFaction():getType() .. '_active' )
            end
            return TexturePacks.getColor( tchar:getFaction():getType() .. '_inactive' )
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
        return tileset:getSprite( character:getBody():getID(), character:getStance() )
    end

    local function selectWorldObjectSprite( worldObject )
        if worldObject:isOpenable() then
            if worldObject:isPassable() then
                return tileset:getSprite( worldObject:getID(), 'open' )
            else
                return tileset:getSprite( worldObject:getID(), 'closed' )
            end
        end
        return tileset:getSprite( worldObject:getID() )
    end

    ---
    -- Selects a sprite from the tileset based on the tile and its contents.
    -- @tparam  Tile    tile    The tile to choose a sprite for.
    -- @tparam  Faction faction The faction to draw for.
    -- @treturn Quad            A quad pointing to a sprite on the tileset.
    --
    local function selectTileSprite( tile, faction )
        if tile:isOccupied() and faction:canSee( tile ) then
            return selectCharacterTile( tile )
        end

        if not tile:getInventory():isEmpty() then
            return tileset:getSprite( 'items' )
        end

        if tile:hasWorldObject() then
            return selectWorldObjectSprite( tile:getWorldObject() )
        end

        return tileset:getSprite( tile:getID() )
    end

    ---
    -- Updates the spritebatch by going through every tile in the map. Only
    -- tiles which have been marked as dirty will be sent to the spritebatch.
    --
    local function updateSpritebatch()
        local faction = factions:getPlayerFaction()
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
    -- Initialises the MapPainter.
    -- @tparam Map      nmap      The map to draw.
    -- @tparam Factions nfactions The factions handler.
    --
    function self:init( nmap, nfactions )
        map, factions = nmap, nfactions

        tileset = TexturePacks.getTileset()
        tw, th = tileset:getTileDimensions()
        TexturePacks.setBackgroundColor()
        spritebatch = love.graphics.newSpriteBatch( tileset:getSpritesheet(), MAX_SPRITES, 'dynamic' )
        initSpritebatch()
    end

    ---
    -- Draws the game's world.
    --
    function self:draw()
        love.graphics.draw( spritebatch, 0, 0 )
    end

    ---
    -- Updates the spritebatch for the game's world.
    --
    function self:update()
        updateSpritebatch()
    end

    return self
end

return MapPainter
