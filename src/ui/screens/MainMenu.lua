local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local UITextButton = require( 'src.ui.elements.UITextButton' )
local UIHorizontalList = require( 'src.ui.elements.lists.UIHorizontalList' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local GridHelper = require( 'src.util.GridHelper' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SplashScreen = {}

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

local BUTTON_LIST_WIDTH = 40
local BUTTON_LIST_Y = 20

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function SplashScreen.new()
    local self = Screen.new()

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local title
    local buttonList
    local debug
    local footer

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function createTitle()
        local font = TexturePacks.getFont()
        title = love.graphics.newText( font:get() )
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
    end

    local function drawDebugInfo()
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

        buttonList = UIHorizontalList.new( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

        local newGameButton = UITextButton.new( lx, ly, 0, 0, 10, 1 )
        newGameButton:init( Translator.getText( 'ui_main_menu_new_game' ), function() ScreenManager.switch( 'gamescreen' ) end )
        buttonList:addChild( newGameButton )

        local loadPreviousGameButton = UITextButton.new( lx, ly, 0, 0, 10, 1 )
        loadPreviousGameButton:init( Translator.getText( 'ui_main_menu_load_game' ), function() ScreenManager.switch( 'loadgame' ) end )
        buttonList:addChild( loadPreviousGameButton )

        local openOptionsButton = UITextButton.new( lx, ly, 0, 0, 10, 1 )
        openOptionsButton:init( Translator.getText( 'ui_main_menu_options' ), function() ScreenManager.switch( 'options' ) end )
        buttonList:addChild( openOptionsButton )

        local changelogButton = UITextButton.new( lx, ly, 0, 0, 10, 1 )
        changelogButton:init( Translator.getText( 'ui_main_menu_changelog' ), function() ScreenManager.switch( 'changelog' ) end )
        buttonList:addChild( changelogButton )

        local exitGameButton = UITextButton.new( lx, ly, 0, 0, 10, 1 )
        exitGameButton:init( Translator.getText( 'ui_main_menu_exit' ), function() love.event.quit() end )
        buttonList:addChild( exitGameButton )
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        createTitle()
        createButtons()

        footer = UICopyrightFooter.new()

        -- Flush the LuaJIT cache to prevent memory leaks caused by cached
        -- upvalues and closures.
        -- @see https://github.com/LuaJIT/LuaJIT/issues/303
        jit.flush()

        collectgarbage( 'collect' )
    end

    function self:draw()
        local font = TexturePacks.getFont()
        font:use()
        love.graphics.draw( title, love.graphics.getWidth() * 0.5 - title:getWidth() * 0.5, TITLE_POSITION * font:getGlyphHeight() )

        buttonList:draw()

        drawDebugInfo()

        footer:draw()
    end

    function self:update()
        buttonList:update()
    end

    function self:keypressed( _, scancode )
        buttonList:keypressed( _, scancode )

        if scancode == 'f1' then
            debug = not debug
        end
    end

    function self:mousemoved()
        buttonList:mousemoved()
    end

    function self:mousereleased()
        buttonList:mousereleased()
    end

    function self:resize( _, _ )
        local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
        local _, sh = GridHelper.getScreenGridDimensions()
        local ly = sh - BUTTON_LIST_Y

        buttonList:setOrigin( lx, ly )
    end

    return self
end

return SplashScreen
