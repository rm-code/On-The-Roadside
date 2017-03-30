---
-- This module takes care of drawing the game's map tiles.
-- It uses a spritebatch to optimise the drawing operation since the map
-- remains static and only needs to be updated when the state of the world
-- changes.
-- Only tiles which are marked as dirty will be updated by the WorldPainter.
--
-- @module WorldPainter
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' );
local Tileset = require( 'src.ui.Tileset' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local WorldPainter = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local FACTIONS = require( 'src.constants.FACTIONS' );

local CHARACTER_COLORS = {
    ACTIVE = {
        [FACTIONS.ALLIED]  = COLORS.DB17,
        [FACTIONS.NEUTRAL] = COLORS.DB09,
        [FACTIONS.ENEMY]   = COLORS.DB05
    },
    INACTIVE = {
        [FACTIONS.ALLIED]  = COLORS.DB15,
        [FACTIONS.NEUTRAL] = COLORS.DB10,
        [FACTIONS.ENEMY]   = COLORS.DB27
    }
}

local STANCES = require('src.constants.Stances');
local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Generates a new instance of the WorldPainter class.
-- @tparam Game game An instance of the game object.
--
function WorldPainter.new( game )
    local self = {};

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local spritebatch;

    love.graphics.setPointSize( 4 );

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Adds an empty sprite for each tile in the map to the spritebatch, gives
    -- each tile a unique identifier and sets it to dirty for the first update.
    -- @tparam Map map The game's world map.
    --
    local function initSpritebatch( map )
        map:iterate( function( tile, x, y )
            local id = spritebatch:add( Tileset.getSprite( 1 ), x * TILE_SIZE, y * TILE_SIZE );
            tile:setSpriteID( id );
            tile:setDirty( true );
        end)
        Log.debug( string.format('Initialised %d tiles.', spritebatch:getCount()), 'WorldPainter' );
    end

    ---
    -- Selects a color which to use when a tile is drawn based on its contents.
    -- @tparam  Tile      tile      The tile to choose a color for.
    -- @tparam  Faction   faction   The faction to draw for.
    -- @tparam  Character character The faction's currently active character.
    -- @treturn table               A table containing RGBA values.
    --
    local function selectTileColor( tile, faction, character )
        -- Hide unexplored tiles.
        if not tile:isExplored( faction:getType() ) then
            return COLORS.DB00;
        end

        -- Dim tiles hidden from the player.
        if not faction:canSee( tile ) then
            return COLORS.DB01;
        end

        if tile:isOccupied() then
            if tile:getCharacter() == character then
                return CHARACTER_COLORS.ACTIVE[tile:getCharacter():getFaction():getType()];
            else
                return CHARACTER_COLORS.INACTIVE[tile:getCharacter():getFaction():getType()];
            end
        end

        if not tile:getInventory():isEmpty() then
            return COLORS.DB16;
        end

        if tile:hasWorldObject() then
            return tile:getWorldObject():getColor();
        end

        return tile:getColor();
    end

    ---
    -- Selects the tile for drawing a tile occupied by a character.
    -- @tparam  Tile tile The tile to pick a sprite for.
    -- @treturn Quad      A quad pointing to the sprite on the active Tileset.
    --
    local function selectCharacterTile( tile )
        local character = tile:getCharacter();
        if character:getBody():getID() == 'dog' then
            return Tileset.getSprite( 101 );
        end
        if character:getStance() == STANCES.STAND then
            if character:getFaction():getType() == FACTIONS.ENEMY then
                return Tileset.getSprite( 3 );
            else
                return Tileset.getSprite( 2 );
            end
        elseif character:getStance() == STANCES.CROUCH then
            return Tileset.getSprite( 32 );
        elseif character:getStance() == STANCES.PRONE then
            return Tileset.getSprite( 23 );
        end
    end

    ---
    -- Selects a sprite from the tileset based on the tile and its contents.
    -- @tparam  Tile    tile    The tile to choose a sprite for.
    -- @tparam  Faction faction The faction to draw for.
    -- @treturn Quad            A quad pointing to a sprite on the tileset.
    --
    local function selectTileSprite( tile, faction )
        if tile:isOccupied() and faction:canSee( tile ) then
            return selectCharacterTile( tile );
        end

        if not tile:getInventory():isEmpty() then
            return Tileset.getSprite( 34 );
        end

        if tile:hasWorldObject() then
            return Tileset.getSprite( tile:getWorldObject():getSprite() );
        end

        return Tileset.getSprite( tile:getSprite() );
    end

    ---
    -- Updates the spritebatch by going through every tile in the map. Only
    -- tiles which have been marked as dirty will be sent to the spritebatch.
    -- @tparam Map      map      The game's world map.
    -- @tparam Factions factions The faction handler.
    --
    local function updateSpritebatch( map, factions )
        local faction = factions:getPlayerFaction();
        map:iterate( function( tile, x, y)
            if tile:isDirty() then
                spritebatch:setColor( selectTileColor( tile, faction, faction:getCurrentCharacter() ));
                spritebatch:set( tile:getSpriteID(), selectTileSprite( tile, faction ), x * TILE_SIZE, y * TILE_SIZE );
                tile:setDirty( false );
            end
        end)
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Initialises the WorldPainter.
    --
    function self:init()
        love.graphics.setBackgroundColor( COLORS.DB00 );
        spritebatch = love.graphics.newSpriteBatch( Tileset.getTileset(), 10000, 'dynamic' );
        initSpritebatch( game:getMap() );
    end

    ---
    -- Draws the game's world.
    --
    function self:draw()
        love.graphics.draw( spritebatch, 0, 0 );
    end

    ---
    -- Updates the spritebatch for the game's world.
    --
    function self:update()
        updateSpritebatch( game:getMap(), game:getFactions() );
    end

    return self;
end

return WorldPainter;
