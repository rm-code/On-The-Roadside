local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local Translator = require( 'src.util.Translator' );
local Outlines = require( 'src.ui.elements.Outlines' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GameOverScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

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
    local tw, th = TexturePacks.getTileDimensions()

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
        px = math.floor( love.graphics.getWidth() / tw ) * 0.5 - math.floor( SCREEN_WIDTH * 0.5 )
        py = math.floor( love.graphics.getHeight() / th ) * 0.5 - math.floor( SCREEN_HEIGHT * 0.5 )
        px, py = px * tw, py * th

        outlines = Outlines.new()
        createOutlines( SCREEN_WIDTH, SCREEN_HEIGHT )
        outlines:refresh()

        text = win and Translator.getText( 'ui_win' ) or Translator.getText( 'ui_lose' );
    end

    function self:draw()
        TexturePacks.setColor( 'sys_background' )
        love.graphics.rectangle( 'fill', px, py, SCREEN_WIDTH * tw, SCREEN_HEIGHT * th )

        outlines:draw( px, py )

        love.graphics.printf( text, px, py + 3 * tw, SCREEN_WIDTH * th, 'center' )
    end

    function self:keypressed()
        ScreenManager.switch( 'mainmenu' );
    end

    return self;
end

return GameOverScreen;
