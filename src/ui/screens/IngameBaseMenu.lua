local Screen = require( 'lib.screenmanager.Screen' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Button = require( 'src.ui.elements.Button' );
local Label = require( 'src.ui.elements.Label' )
local VerticalList = require( 'src.ui.elements.VerticalList' );
local SaveHandler = require( 'src.SaveHandler' );
local Translator = require( 'src.util.Translator' );
local Outlines = require( 'src.ui.elements.Outlines' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local IngameBaseMenu = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SCREEN_WIDTH  = 10
local SCREEN_HEIGHT = 7;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function IngameBaseMenu.new()
    local self = Screen.new();

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local game;
    local buttonList;
    local header

    local outlines
    local px, py;
    local tw, th

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function createOutlines( w, h )
        for x = 0, w - 1 do
            for y = 0, h - 1 do
                if x == 0 or x == (w - 1) or y == 0 or y == (h - 1) then
                    outlines:add( x, y )
                end
                if y == 2 then
                    outlines:add( x, y )
                end
            end
        end
    end

    local function saveGame()
        SaveHandler.save( game:serialize() );
        ScreenManager.pop();
    end

    local function openHelpScreen()
        ScreenManager.push( 'help' );
    end

    local function exitToMainMenu()
        ScreenManager.switch( 'mainmenu' );
    end

    local function createButtons()
        buttonList = VerticalList.new( px * tw, (py+3) * th, SCREEN_WIDTH * tw, th )
        buttonList:addElement( Button.new( Translator.getText( 'ui_ingame_save_game' ), saveGame ))
        buttonList:addElement( Button.new( Translator.getText( 'ui_ingame_open_help' ), openHelpScreen ))
        buttonList:addElement( Button.new( Translator.getText( 'ui_ingame_exit' ), exitToMainMenu ))
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( ngame )
        game = ngame;

        tw, th = TexturePacks.getTileDimensions()
        px, py = GridHelper.centerElement( SCREEN_WIDTH, SCREEN_HEIGHT )

        outlines = Outlines.new( px, py )
        createOutlines( SCREEN_WIDTH, SCREEN_HEIGHT )
        outlines:refresh()

        createButtons();

        header = Label.new( Translator.getText( 'ui_ingame_paused' ), 'ui_label', 'center' )
    end

    function self:draw()
        TexturePacks.setColor( 'sys_background' );
        love.graphics.rectangle( 'fill', px*tw, py*th, SCREEN_WIDTH * tw, SCREEN_HEIGHT * th )

        outlines:draw()

        buttonList:draw();
        header:draw( (px+1) * tw, (py+1) * th, (SCREEN_WIDTH - 2) * tw, th )
    end

    function self:update()
        buttonList:update();
    end

    function self:keypressed( _, scancode )
        buttonList:keypressed( _, scancode );

        if scancode == 'escape' then
            ScreenManager.pop();
        end
    end

    function self:mousemoved()
        buttonList:mousemoved();
    end

    function self:mousereleased()
        buttonList:mousereleased();
    end

    function self:resize( sx, sy )
        px = math.floor( sx / tw ) * 0.5 - math.floor( SCREEN_WIDTH  * 0.5 )
        py = math.floor( sy / th ) * 0.5 - math.floor( SCREEN_HEIGHT * 0.5 )
        px, py = px * tw, py * th
    end

    return self;
end

return IngameBaseMenu
