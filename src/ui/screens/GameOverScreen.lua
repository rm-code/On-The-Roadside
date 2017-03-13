local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local Tileset = require( 'src.ui.Tileset' );
local Translator = require( 'src.util.Translator' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GameOverScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local TILE_SIZE = require( 'src.constants.TileSize' );
local SCREEN_WIDTH  = 30;
local SCREEN_HEIGHT = 16;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function GameOverScreen.new()
    local self = Screen.new();

    local text;
    local grid;
    local px, py;

    ---
    -- Returns the value of the grid for this position or 0 for coordinates
    -- outside of the grid.
    -- @param x (number) The x coordinate in the grid.
    -- @param y (number) The y coordinate in the grid.
    -- @return  (number) The grid index or 0.
    --
    local function getGridIndex( x, y )
        if not grid[x] then
            return 0;
        elseif not grid[x][y] then
            return 0;
        end
        return grid[x][y];
    end

    local function fillGrid( w, h )
        for x = 0, w - 1 do
            for y = 0, h - 1 do
                grid[x] = grid[x] or {};
                grid[x][y] = 0;

                -- Draw screen borders.
                if x == 0 or x == (w - 1) or y == 0 or y == (h - 1) then
                    grid[x][y] = 1;
                end
            end
        end
    end

    ---
    -- Checks the NSEW tiles around the given coordinates in the grid and returns
    -- an index for the appropriate sprite to use.
    -- @param x (number) The x coordinate in the grid.
    -- @param y (number) The y coordinate in the grid.
    -- @return  (number) The sprite index.
    --
    local function determineTile( x, y )
        if -- Connected to all sides.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 198;
        elseif -- Vertically connected.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 180;
        elseif -- Horizontally connected.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 197;
        elseif -- Bottom right corner.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 218;
        elseif -- Top left corner.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 219;
        elseif -- Top right corner.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 192;
        elseif -- Bottom left corner.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 193;
        elseif -- T-intersection down.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) == 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 195;
        elseif -- T-intersection up.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) == 0 then
                return 194;
        elseif -- T-intersection right.
            getGridIndex( x - 1, y     ) == 0 and
            getGridIndex( x + 1, y     ) ~= 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 196;
        elseif -- T-intersection left.
            getGridIndex( x - 1, y     ) ~= 0 and
            getGridIndex( x + 1, y     ) == 0 and
            getGridIndex( x    , y - 1 ) ~= 0 and
            getGridIndex( x    , y + 1 ) ~= 0 then
                return 181;
        end
        return 1;
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( win )
        px = math.floor( love.graphics.getWidth() / TILE_SIZE ) * 0.5 - math.floor( SCREEN_WIDTH * 0.5 );
        py = math.floor( love.graphics.getHeight() / TILE_SIZE ) * 0.5 - math.floor( SCREEN_HEIGHT * 0.5 );
        px, py = px * TILE_SIZE, py * TILE_SIZE;

        grid = {};
        fillGrid( SCREEN_WIDTH, SCREEN_HEIGHT );

        text = win and Translator.getText( 'ui_win' ) or Translator.getText( 'ui_lose' );
    end

    function self:draw()
        local ts = Tileset.getTileset();
        love.graphics.setColor( COLORS.DB00 );
        love.graphics.rectangle( 'fill', px, py, SCREEN_WIDTH * TILE_SIZE, SCREEN_HEIGHT * TILE_SIZE );
        love.graphics.setColor( COLORS.DB22 );

        for x = 0, SCREEN_WIDTH - 1 do
            for y = 0, SCREEN_HEIGHT - 1 do
                if grid[x][y] ~= 0 then
                    love.graphics.draw( ts, Tileset.getSprite( determineTile( x, y )), px + x * TILE_SIZE, py + y * TILE_SIZE );
                end
            end
        end

        love.graphics.printf( text, px, py + 3 * TILE_SIZE, SCREEN_WIDTH * TILE_SIZE, 'center' );
    end

    function self:keypressed()
        ScreenManager.switch( 'mainmenu' );
    end

    return self;
end

return GameOverScreen;
