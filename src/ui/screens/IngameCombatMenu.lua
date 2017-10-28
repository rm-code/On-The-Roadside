local Screen = require( 'lib.screenmanager.Screen' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Button = require( 'src.ui.elements.Button' );
local VerticalList = require( 'src.ui.elements.VerticalList' );
local SaveHandler = require( 'src.SaveHandler' );
local Translator = require( 'src.util.Translator' );
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local IngameCombatMenu = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 14
local UI_GRID_HEIGHT = 8

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function IngameCombatMenu.new()
    local self = Screen.new();

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local game;
    local buttonList;

    local background
    local outlines
    local x, y
    local tw, th

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Generates the outlines for this screen.
    --
    local function generateOutlines()
        outlines = UIOutlines.new( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        -- Horizontal borders.
        for ox = 0, UI_GRID_WIDTH-1 do
            outlines:add( ox, 0                ) -- Top
            outlines:add( ox, 2                ) -- Header
            outlines:add( ox, UI_GRID_HEIGHT-1 ) -- Bottom
        end

        -- Vertical outlines.
        for oy = 0, UI_GRID_HEIGHT-1 do
            outlines:add( 0,               oy ) -- Left
            outlines:add( UI_GRID_WIDTH-1, oy ) -- Right
        end

        outlines:refresh()
    end

    local function saveGame()
        SaveHandler.save( game:serialize() );
        ScreenManager.pop();
    end

    local function openHelpScreen()
        ScreenManager.push( 'help' );
    end

    local function exitToBase()
        ScreenManager.pop() -- Ingame
        ScreenManager.pop() -- Combat
        ScreenManager.push( 'base', game:getFactions():getPlayerFaction() )
    end

    local function exitToMainMenu()
        ScreenManager.switch( 'mainmenu' );
    end

    local function createButtons()
        buttonList = VerticalList.new( x*tw, (y+3) * th, UI_GRID_WIDTH * tw, th )
        buttonList:addElement( Button.new( Translator.getText( 'ui_ingame_save_game' ), saveGame ))
        buttonList:addElement( Button.new( Translator.getText( 'ui_ingame_open_help' ), openHelpScreen ))
        buttonList:addElement( Button.new( Translator.getText( 'ui_ingame_abort_mission' ), exitToBase ))
        buttonList:addElement( Button.new( Translator.getText( 'ui_ingame_exit' ), exitToMainMenu ))
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( ngame )
        game = ngame;

        tw, th = TexturePacks.getTileDimensions()
        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        background = UIBackground.new( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        generateOutlines()

        createButtons();
    end

    function self:draw()
        background:draw()
        outlines:draw()

        buttonList:draw();
        love.graphics.printf( Translator.getText( 'ui_ingame_paused' ), (x+1) * tw, (y+1) * th, (UI_GRID_WIDTH - 2) * tw, 'center' )
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

    return self;
end

return IngameCombatMenu
