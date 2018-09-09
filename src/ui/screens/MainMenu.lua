---
-- @module MainMenu
--

local Screen = require( 'src.ui.screens.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local UIButton = require( 'src.ui.elements.UIButton' )
local UIHorizontalList = require( 'src.ui.elements.lists.UIHorizontalList' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local GridHelper = require( 'src.util.GridHelper' )
local Translator = require( 'src.util.Translator' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local Settings = require( 'src.Settings' )
local UIMenuTitle = require( 'src.ui.elements.UIMenuTitle' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainMenu = Screen:subclass( 'MainMenu' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TITLE_POSITION = 2
local BUTTON_LIST_WIDTH = 60
local BUTTON_LIST_Y = 20

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function drawDebugInfo( debug )
    local font = TexturePacks.getFont()
    if debug then
        TexturePacks.setColor( 'ui_text_dim' )
        love.graphics.print( love.timer.getFPS() .. ' FPS', font:getGlyphWidth(), font:getGlyphWidth() )
        love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', font:getGlyphWidth(), font:getGlyphWidth() + font:getGlyphHeight() )
        TexturePacks.resetColor()
    end
end

local function createButtons()
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )

    local _, sh = GridHelper.getScreenGridDimensions()
    local ly = sh - BUTTON_LIST_Y

    local buttonList = UIHorizontalList( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

    local newGameButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'gamescreen' ) end, Translator.getText( 'ui_main_menu_new_game' ))
    buttonList:addChild( newGameButton )

    local loadPreviousGameButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'loadgame' ) end, Translator.getText( 'ui_main_menu_load_game' ))
    buttonList:addChild( loadPreviousGameButton )

    local openOptionsButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'options' ) end, Translator.getText( 'ui_main_menu_options' ))
    buttonList:addChild( openOptionsButton )

    -- Only show map editor if it has been activated in the options.
    if Settings.getIngameEditor() then
        local mapEditorButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'prefabeditor' ) end, Translator.getText( 'ui_main_menu_mapeditor' ))
        buttonList:addChild( mapEditorButton )
    end

    local changelogButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'changelog' ) end, Translator.getText( 'ui_main_menu_changelog' ))
    buttonList:addChild( changelogButton )

    local exitGameButton = UIButton( lx, ly, 0, 0, 10, 1, function() love.event.quit() end, Translator.getText( 'general_exit' ))
    buttonList:addChild( exitGameButton )

    return buttonList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function MainMenu:initialize()
    love.mouse.setVisible( false )

    self.title = UIMenuTitle( Translator.getText( 'ui_title_main_menu' ), TITLE_POSITION )
    self.buttonList = createButtons()

    self.container = UIContainer()
    self.container:register( self.buttonList )

    self.footer = UICopyrightFooter()

    collectgarbage( 'collect' )
end

function MainMenu:draw()
    local font = TexturePacks.getFont()
    font:use()

    self.title:draw()

    self.container:draw()

    drawDebugInfo( self.debug )

    self.footer:draw()
end

function MainMenu:update()
    self.container:update()
end

function MainMenu:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'left' then
        self.container:command( 'left' )
    elseif scancode == 'right' then
        self.container:command( 'right' )
    elseif scancode == 'return' then
        self.container:command( 'activate' )
    end

    if scancode == 'f1' then
        self.debug = not self.debug
    end
end

function MainMenu:mousemoved()
    love.mouse.setVisible( true )
end

function MainMenu:mousereleased()
    self.container:mousecommand( 'activate' )
end

function MainMenu:resize( _, _ )
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
    local _, sh = GridHelper.getScreenGridDimensions()
    local ly = sh - BUTTON_LIST_Y

    self.buttonList:setOrigin( lx, ly )
end

return MainMenu
