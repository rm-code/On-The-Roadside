local FactionManager = require( 'src.characters.FactionManager' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );

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
        [FACTIONS.NEUTRAL] = COLORS.DB12,
        [FACTIONS.ENEMY]   = COLORS.DB27
    }
}

local TILE_SIZE = require( 'src.constants.TileSize' );
local TILESET = love.graphics.newImage( 'res/img/16x16_sm.png' );

local TILE_SPRITES = {};
for x = 1, TILESET:getWidth() / TILE_SIZE do
    for y = 1, TILESET:getHeight() / TILE_SIZE do
        TILE_SPRITES[#TILE_SPRITES + 1] = love.graphics.newQuad(( y - 1 ) * TILE_SIZE, ( x - 1 ) * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    end
end

print( "Loaded " .. #TILE_SPRITES .. " sprites!" );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local WorldPainter = {};

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
            local id = spritebatch:add( TILE_SPRITES[1], x * TILE_SIZE, y * TILE_SIZE );
            tile:setID( id );
            tile:setDirty( true );
        end)
        print( string.format('Initialised %d tiles.', spritebatch:getCount()) );
    end

    ---
    -- Selects a color which to use when a tile is drawn based on its contents.
    -- @param tile (Tile)  The tile to choose a color for.
    -- @return     (table) A table containing RGBA values.
    --
    local function selectTileColor( tile )
        -- Hide unexplored tiles.
        if not FactionManager.getFaction():hasExplored( tile ) then
            return COLORS.DB00;
        end

        -- Dim tiles hidden from the player.
        if not FactionManager.getFaction():canSee( tile ) then
            return COLORS.DB01;
        end

        if tile:isOccupied() then
            if tile:getCharacter() == FactionManager.getCurrentCharacter() then
                return CHARACTER_COLORS.ACTIVE[tile:getCharacter():getFaction()];
            else
                return CHARACTER_COLORS.INACTIVE[tile:getCharacter():getFaction()];
            end
        end

        if not tile:getStorage():isEmpty() then
            return COLORS.DB16;
        end

        if tile:hasWorldObject() then
            return tile:getWorldObject():getColor();
        end

        return tile:getColor();
    end

    ---
    -- Selects a sprite from the tileset based on the tile and its contents.
    -- @param tile (Tile) The tile to choose a sprite for.
    -- @return     (Quad) A quad pointing to a sprite on the tileset.
    --
    local function selectTileSprite( tile )
        if tile:isOccupied() and FactionManager.getFaction():canSee( tile ) then
            if tile:getCharacter():getFaction() == FACTIONS.ENEMY then
                return TILE_SPRITES[3];
            else
                return TILE_SPRITES[2];
            end
        end

        if not tile:getStorage():isEmpty() then
            return TILE_SPRITES[34];
        end

        if tile:hasWorldObject() then
            return TILE_SPRITES[tile:getWorldObject():getSprite()];
        end

        return TILE_SPRITES[tile:getSprite()];
    end

    ---
    -- Updates the spritebatch by going through every tile in the map. Only
    -- tiles which have been marked as dirty will be sent to the spritebatch.
    -- @param map (Map) The game's world map.
    --
    local function updateSpritebatch( map )
        map:iterate( function( tile, x, y)
            if tile:isDirty() then
                spritebatch:setColor( selectTileColor( tile ) );
                spritebatch:set( tile:getID(), selectTileSprite( tile ), x * TILE_SIZE, y * TILE_SIZE );
                tile:setDirty( false );
            end
        end)
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        love.graphics.setBackgroundColor( COLORS.DB00 );
        spritebatch = love.graphics.newSpriteBatch( TILESET, 10000, 'dynamic' );
        initSpritebatch( game:getMap() );
    end

    function self:draw()
        love.graphics.draw( spritebatch, 0, 0 );

        ProjectileManager.iterate( function( x, y )
            love.graphics.points( x * TILE_SIZE, y * TILE_SIZE );
        end)
    end

    function self:update()
        updateSpritebatch( game:getMap() );
    end

    return self;
end

return WorldPainter;
