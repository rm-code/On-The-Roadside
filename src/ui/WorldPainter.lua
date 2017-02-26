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
local FACTIONS = require( 'src.constants.Factions' );

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

function WorldPainter.new( game )
    local self = {};

    local spritebatch;

    love.graphics.setPointSize( 4 );

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Adds an empty sprite for each tile in the map to the spritebatch, gives
    -- each tile a unique identifier and sets it to dirty for the first update.
    -- @param map (Map) The game's world map.
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
    -- @param tile      (Tile)      The tile to choose a color for.
    -- @param faction   (Faction)   The faction to draw for.
    -- @param character (Character) The faction's currently active character.
    -- @return          (table)     A table containing RGBA values.
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
    -- @param tile    (Tile)    The tile to choose a sprite for.
    -- @param faction (Faction) The faction to draw for.
    -- @return        (Quad)    A quad pointing to a sprite on the tileset.
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
    -- @param map      (Map)      The game's world map.
    -- @param factions (factions) The faction handler.
    --
    local function updateSpritebatch( map, factions )
        -- NOTE: Change this line to enable drawing for the AI.
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

    function self:init()
        love.graphics.setBackgroundColor( COLORS.DB00 );
        spritebatch = love.graphics.newSpriteBatch( Tileset.getTileset(), 10000, 'dynamic' );
        initSpritebatch( game:getMap() );
    end

    function self:draw()
        love.graphics.draw( spritebatch, 0, 0 );
    end

    function self:update()
        updateSpritebatch( game:getMap(), game:getFactions() );
    end

    return self;
end

return WorldPainter;
