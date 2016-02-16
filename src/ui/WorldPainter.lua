local CharacterManager = require( 'src.characters.CharacterManager' );
local Messenger = require( 'src.Messenger' );

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
        [FACTIONS.NEUTRAL] = COLORS.DB12,
        [FACTIONS.ENEMY]   = COLORS.DB27
    }
}

local TILE_SIZE = require( 'src.constants.TileSize' );
local TILESET = love.graphics.newImage( 'res/tiles/16x16_sm.png' );
local TILE_SPRITES = {
    EMPTY       = love.graphics.newQuad(  0 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    ALLIED      = love.graphics.newQuad(  1 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    ENEMY       = love.graphics.newQuad(  2 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    WALL        = love.graphics.newQuad(  3 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    DOOR_CLOSED = love.graphics.newQuad( 11 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    FLOOR       = love.graphics.newQuad( 14 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    DOOR_OPEN   = love.graphics.newQuad( 15 * TILE_SIZE, 5 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
}

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

    local mouseX, mouseY = 0, 0;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- @param value (number) The cost of the node.
    -- @param total (number) The total number of nodes in the path.
    --
    local function selectPathNodeColor( value, total )
        local fraction = value / total;
        if fraction <= 0.1 then
            return COLORS.DB27;
        elseif fraction <= 0.4 then
            return COLORS.DB05;
        elseif fraction <= 0.6 then
            return COLORS.DB08;
        elseif fraction <= 1.0 then
            return COLORS.DB09;
        end
    end

    ---
    -- Adds an empty sprite for each tile in the map to the spritebatch, gives
    -- each tile a unique identifier and sets it to dirty for the first update.
    -- @param map (Map) The game's world map.
    --
    local function initSpritebatch( map )
        map:iterate( function( tile, x, y )
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
            return COLORS.DB00;
        end

        -- Change colors for tiles which are part of a character's path.
        if CharacterManager.getCurrentCharacter():hasPath() then
            local path = CharacterManager.getCurrentCharacter():getPath();
            local index = path:contains( tile );
            if index then
                return selectPathNodeColor( index, path:getLength() );
            end
        end

        -- Dim tiles hidden from the player.
        if not tile:isVisible() then
            return COLORS.DB01;
        end

        if tile:isOccupied() then
            if tile:getCharacter() == CharacterManager.getCurrentCharacter() then
                return CHARACTER_COLORS.ACTIVE[tile:getCharacter():getFaction()];
            else
                return CHARACTER_COLORS.INACTIVE[tile:getCharacter():getFaction()];
            end
        elseif tile:getWorldObject():instanceOf( 'Door' ) then
            return COLORS.DB03;
        elseif tile:getWorldObject():instanceOf( 'Floor' ) then
            return COLORS.DB25;
        elseif tile:getWorldObject():instanceOf( 'Wall' ) then
            return COLORS.DB23;
        end
    end

    ---
    -- Selects a sprite from the tileset based on the tile and its contents.
    -- @param tile (Tile) The tile to choose a sprite for.
    -- @return     (Quad) A quad pointing to a sprite on the tileset.
    --
    local function selectTileSprite( tile )
        if tile:isOccupied() and tile:isVisible() then
            if tile:getCharacter():getFaction() == FACTIONS.ENEMY then
                return TILE_SPRITES.ENEMY;
            else
                return TILE_SPRITES.ALLIED;
            end
        end

        if tile:getWorldObject():instanceOf( 'Wall' ) then
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

    ---
    -- Draws a mouse cursor that snaps to the grid.
    --
    local function drawMouseCursor()
        love.graphics.rectangle( 'line', mouseX * TILE_SIZE, mouseY * TILE_SIZE, TILE_SIZE, TILE_SIZE );
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

        drawMouseCursor();

        -- Draw tile coordinates.
        love.graphics.print( 'Coords: ' .. mouseX .. ', ' .. mouseY, 10, love.graphics.getHeight() - 20 );
    end

    function self:update()
        local map = game:getMap();
        map:resetVisibility();
        for _, char in ipairs( CharacterManager.getCharacters() ) do
            map:calculateVisibility( char:getTile(), char:getViewRange() );
            if char:hasPath() then
                char:getPath():refresh();
            end
        end
        updateSpritebatch( game:getMap() );
    end

    Messenger.observe( 'MOUSE_MOVED', function( mx, my )
        mouseX, mouseY = mx, my;
    end)

    return self;
end

return WorldPainter;
