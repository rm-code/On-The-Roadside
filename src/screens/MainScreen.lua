local Screen = require( 'lib.screenmanager.Screen' );
local Map = require( 'src.map.Map' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local TurnManager = require( 'src.combat.TurnManager' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.Colors' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = 16;
local TILESET = love.graphics.newImage( 'res/tiles/16x16_sm.png' );
local TILE_SPRITES = {
    EMPTY       = love.graphics.newQuad(  0 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    CHARACTER   = love.graphics.newQuad(  1 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    WALL        = love.graphics.newQuad(  3 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    DOOR_CLOSED = love.graphics.newQuad( 11 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    FLOOR       = love.graphics.newQuad( 14 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    DOOR_OPEN   = love.graphics.newQuad( 15 * TILE_SIZE, 5 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local spritebatch;
    local turnManager;
    local map;

    ---
    -- Adds an empty sprite for each tile in the map to the spritebatch, gives
    -- each square a unique identifier and sets it to dirty for the first update.
    --
    local function initSpritebatch()
        map:iterate( function( tile, x, y)
            local id = spritebatch:add( TILE_SPRITES.EMPTY, x * TILE_SIZE, y * TILE_SIZE );
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
        if not tile:isExplored() then
            return COLORS.BASE00;
        end

        -- Dim tiles hidden from the player.
        if not tile:isVisible() then
            return COLORS.BASE01;
        end

        if tile:isOccupied() then
            if tile:getCharacter() == CharacterManager.getCurrentCharacter() then
                return COLORS.BASE0E;
            else
                return COLORS.BASE0B;
            end
        elseif tile:getWorldObject():instanceOf( 'Door' ) then
            return COLORS.BASE08;
        elseif tile:getWorldObject():instanceOf( 'Floor' ) then
            return COLORS.BASE03;
        elseif tile:getWorldObject():instanceOf( 'Wall' ) then
            return COLORS.BASE05;
        end
    end

    ---
    -- Selects a sprite from the tileset based on the tile and its contents.
    -- @param tile (Tile) The tile to choose a sprite for.
    -- @return     (Quad) A quad pointing to a sprite on the tileset.
    --
    local function selectTileSprite( tile )
        if tile:isOccupied() then
            return TILE_SPRITES.CHARACTER;
        elseif tile:getWorldObject():instanceOf( 'Wall' ) then
            return TILE_SPRITES.WALL;
        elseif tile:getWorldObject():instanceOf( 'Floor' ) then
            return TILE_SPRITES.FLOOR;
        elseif tile:getWorldObject():instanceOf( 'Door' ) then
            if tile:getWorldObject():isPassable() then
                return TILE_SPRITES.DOOR_OPEN;
            else
                return TILE_SPRITES.DOOR_CLOSED;
            end
        end
    end

    ---
    -- Updates the spritebatch by going through every tile in the map. Only
    -- tiles which have been marked as dirty will be sent to the spritebatch.
    --
    local function updateSpritebatch()
        map:iterate( function( tile, x, y)
            if tile:isDirty() then
                spritebatch:setColor( selectTileColor( tile ) );
                spritebatch:set( tile:getID(), selectTileSprite( tile ), x * TILE_SIZE, y * TILE_SIZE );
                tile:setDirty( false );
            end
        end)
    end

    ---
    -- Updates the field of view on the map.
    --
    local function updateFOV()
        map:resetVisibility();
        for _, char in ipairs( CharacterManager.getCharacters() ) do
            map:calculateVisibility( char:getTile() );
        end
    end

    function self:init()
        map = Map.new();
        map:init();

        CharacterManager.newCharacter( map:getTileAt( 2, 2 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 3 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 4 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 5 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 6 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 7 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 8 ));

        turnManager = TurnManager.new( map );

        spritebatch = love.graphics.newSpriteBatch( TILESET, 10000, 'dynamic' );
        initSpritebatch();

        love.graphics.setBackgroundColor( COLORS.BASE00 );
    end

    function self:draw()
        love.graphics.draw( spritebatch, 0, 0 );

        local mx, my = love.mouse.getPosition();
        love.graphics.setColor( COLORS.BASE07 );
        love.graphics.rectangle( 'line', math.floor( mx / TILE_SIZE ) * TILE_SIZE, math.floor( my / TILE_SIZE ) * TILE_SIZE, TILE_SIZE, TILE_SIZE )
    end

    function self:update( dt )
        updateSpritebatch();
        updateFOV();
        turnManager:update( dt )
    end

    function self:keypressed( key )
        turnManager:keypressed( key );
    end

    function self:mousepressed( mx, my, button )
        local gx, gy = math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE );
        turnManager:mousepressed( gx, gy, button );
    end

    return self;
end

return MainScreen;
