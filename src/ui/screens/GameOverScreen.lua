local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local Translator = require( 'src.util.Translator' );
local Outlines = require( 'src.ui.elements.Outlines' )

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
    local outlines
    local px, py;

    local function createOutlines( w, h )
        for x = 0, w - 1 do
            for y = 0, h - 1 do
                if x == 0 or x == (w - 1) or y == 0 or y == (h - 1) then
                    outlines:add( x, y )
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( win )
        px = math.floor( love.graphics.getWidth() / TILE_SIZE ) * 0.5 - math.floor( SCREEN_WIDTH * 0.5 );
        py = math.floor( love.graphics.getHeight() / TILE_SIZE ) * 0.5 - math.floor( SCREEN_HEIGHT * 0.5 );
        px, py = px * TILE_SIZE, py * TILE_SIZE;

        outlines = Outlines.new()
        createOutlines( SCREEN_WIDTH, SCREEN_HEIGHT )
        outlines:refresh()

        text = win and Translator.getText( 'ui_win' ) or Translator.getText( 'ui_lose' );
    end

    function self:draw()
        love.graphics.setColor( COLORS.DB00 );
        love.graphics.rectangle( 'fill', px, py, SCREEN_WIDTH * TILE_SIZE, SCREEN_HEIGHT * TILE_SIZE );
        love.graphics.setColor( COLORS.DB22 );

        outlines:draw( px, py )

        love.graphics.printf( text, px, py + 3 * TILE_SIZE, SCREEN_WIDTH * TILE_SIZE, 'center' );
    end

    function self:keypressed()
        ScreenManager.switch( 'mainmenu' );
    end

    return self;
end

return GameOverScreen;
