local Screen = require( 'lib.screenmanager.Screen' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local SaveHandler = require( 'src.SaveHandler' );
local Translator = require( 'src.util.Translator' );
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UITextButton = require( 'src.ui.elements.UITextButton' )
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
        outlines = UIOutlines( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

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

    local function createButtons()
        local lx, ly = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        buttonList = UIVerticalList( lx, ly, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        local saveGameButton = UITextButton( lx, ly, 0, 3, UI_GRID_WIDTH, 1, Translator.getText( 'ui_ingame_save_game' ), saveGame )
        buttonList:addChild( saveGameButton )

        local openHelpButton = UITextButton( lx, ly, 0, 4, UI_GRID_WIDTH, 1, Translator.getText( 'ui_ingame_open_help' ), function() ScreenManager.push( 'help' ) end )
        buttonList:addChild( openHelpButton )

        local exitButton = UITextButton( lx, ly, 0, 5, UI_GRID_WIDTH, 1, Translator.getText( 'ui_ingame_exit' ), function() ScreenManager.switch( 'mainmenu' ) end )
        buttonList:addChild( exitButton )

        local resumeButton = UITextButton( lx, ly, 0, 6, UI_GRID_WIDTH, 1, Translator.getText( 'ui_ingame_resume' ), function() ScreenManager.pop() end )
        buttonList:addChild( resumeButton )
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( ngame )
        game = ngame;

        tw, th = TexturePacks.getTileDimensions()
        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        background = UIBackground( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

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
        if scancode == 'up' then
            buttonList:command( 'up' )
        elseif scancode == 'down' then
            buttonList:command( 'down' )
        elseif scancode == 'return' then
            buttonList:command( 'activate' )
        end

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

    function self:resize( _, _ )
        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
        background:setOrigin( x, y )
        outlines:setOrigin( x, y )
        buttonList:setOrigin( x, y )
    end

    return self;
end

return IngameCombatMenu
