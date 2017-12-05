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

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainMenu = Screen:subclass( 'MainMenu' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TITLE_POSITION = 2
local TITLE_STRING = {
    "             @@@@    @@   @@       @@@@@@@  @@@  @@@  @@@@@@@            ",
    "           @@@@@@@@  @@@  @@@      @@@@@@@  @@@  @@@  @@@@@@@@           ",
    "           @@!  @@@  @@!@ @@@        @@!    @@!  @@@  @@!                ",
    "           !@!  @!@  !@!!@!@!        !@!    !@!  @!@  !@!                ",
    "           @!@  !@!  @!@ !!@!        @!!    @!@!@!@!  @!!!:!             ",
    "           !@!  !!!  !@!  !!!        !!!    !!!@!!!!  !!!!!:             ",
    "           !!:  !!!  !!:  !!!        !!:    !!:  !!!  !!:                ",
    "           :!:  !:!  :!:  !:!        :!:    :!:  !:!  :!:                ",
    "           :!:::!!:   ::   ::         ::     ::   !:  ::!::!!            ",
    "             :!::      :    :          :      :    :  :!:::::!           ",
    "                                                                         ",
    "@@@@@@@     @@@@     @@@@@@   @@@@@@     @@@@@    @@@  @@@@@@@   @@@@@@@ ",
    "@@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@   @@@  @@@@@@@@  @@@@@@@@",
    "@@!  @@@  @@!  @@@  @@!  @@@  @@!  @@@  !@@       @@!  @@!  @@@  @@!     ",
    "!@!  @!@  !@!  @!@  !@!  @!@  !@!  @!@  !@!       !@!  !@!  @!@  !@!     ",
    "@!@!!@!   @!@  !@!  @!@!@!@!  @!@  !@!  !!@@!!    !!@  @!@  !@!  @!!!:!  ",
    "!!@!@!    !@!  !!!  !!!@!!!!  !@!  !!!   !!@!!!   !!!  !@!  !!!  !!!!!:  ",
    "!!: :!!   !!:  !!!  !!:  !!!  !!:  !!!       !:!  !!:  !!:  !!!  !!:     ",
    ":!:  !:!  :!:  !:!  :!:  !:!  :!:  !:!      !:!   :!:  :!:  !:!  :!:     ",
    " ::   !:  ::!:!!::   ::   ::  !:.:.:::  ::!::::    ::  !:!!::.:  ::!:.:: ",
    "  !    :    ::!:      !    :  ::::..:    :::..      :  ::..:.:   ::..::.:",
}

local BUTTON_LIST_WIDTH = 60
local BUTTON_LIST_Y = 20

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function createTitle()
    local font = TexturePacks.getFont()
    local title = love.graphics.newText( font:get() )

    for i, line in ipairs( TITLE_STRING ) do
        local coloredtext = {}
        for w in string.gmatch( line, '.' ) do
            if w == '@' then
                coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_1' )
                coloredtext[#coloredtext + 1] = 'O'
            elseif w == '!' then
                coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_2' )
                coloredtext[#coloredtext + 1] = w
            else
                coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_3' )
                coloredtext[#coloredtext + 1] = w
            end
            title:add( coloredtext, 0, i * font:get():getHeight() )
        end
    end

    return title
end

local function drawTitle( title )
    local cx, _ = GridHelper.centerElement( GridHelper.pixelsToGrid( title:getWidth(), title:getHeight() * #TITLE_STRING ))
    local tw, _ = TexturePacks.getTileDimensions()
    love.graphics.draw( title, cx * tw, TITLE_POSITION * TexturePacks.getFont():getGlyphHeight() )
end

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
        local mapEditorButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'mapeditor' ) end, Translator.getText( 'ui_main_menu_mapeditor' ))
        buttonList:addChild( mapEditorButton )
    end

    local changelogButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'changelog' ) end, Translator.getText( 'ui_main_menu_changelog' ))
    buttonList:addChild( changelogButton )

    local exitGameButton = UIButton( lx, ly, 0, 0, 10, 1, function() love.event.quit() end, Translator.getText( 'ui_main_menu_exit' ))
    buttonList:addChild( exitGameButton )

    return buttonList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function MainMenu:initialize()
    love.mouse.setVisible( false )

    self.title = createTitle()
    self.buttonList = createButtons()

    self.container = UIContainer()
    self.container:register( self.buttonList )

    self.footer = UICopyrightFooter.new()

    -- Flush the LuaJIT cache to prevent memory leaks caused by cached
    -- upvalues and closures.
    -- @see https://github.com/LuaJIT/LuaJIT/issues/303
    jit.flush()

    collectgarbage( 'collect' )
end

function MainMenu:draw()
    local font = TexturePacks.getFont()
    font:use()

    drawTitle( self.title )

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
