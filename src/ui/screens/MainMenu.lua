local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local UIButton = require( 'src.ui.elements.UIButton' )
local UIHorizontalList = require( 'src.ui.elements.lists.UIHorizontalList' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local GridHelper = require( 'src.util.GridHelper' )
local Translator = require( 'src.util.Translator' )
local UIContainer = require( 'src.ui.elements.UIContainer' )

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
    local container

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

    local function drawTitle()
        local cx, _ = GridHelper.centerElement( GridHelper.pixelsToGrid( title:getWidth(), title:getHeight() * #TITLE_STRING ))
        local tw, _ = TexturePacks.getTileDimensions()
        love.graphics.draw( title, cx * tw, TITLE_POSITION * TexturePacks.getFont():getGlyphHeight() )
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

        buttonList = UIHorizontalList( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

        local newGameButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'gamescreen' ) end, Translator.getText( 'ui_main_menu_new_game' ))
        buttonList:addChild( newGameButton )

        local loadPreviousGameButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'loadgame' ) end, Translator.getText( 'ui_main_menu_load_game' ))
        buttonList:addChild( loadPreviousGameButton )

        local openOptionsButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'options' ) end, Translator.getText( 'ui_main_menu_options' ))
        buttonList:addChild( openOptionsButton )

        local changelogButton = UIButton( lx, ly, 0, 0, 10, 1, function() ScreenManager.switch( 'changelog' ) end, Translator.getText( 'ui_main_menu_changelog' ))
        buttonList:addChild( changelogButton )

        local exitGameButton = UIButton( lx, ly, 0, 0, 10, 1, function() love.event.quit() end, Translator.getText( 'ui_main_menu_exit' ))
        buttonList:addChild( exitGameButton )
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        love.mouse.setVisible( false )

        createTitle()
        createButtons()

        container = UIContainer()
        container:register( buttonList )

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

        drawTitle()

        container:draw()

        drawDebugInfo()

        footer:draw()
    end

    function self:update()
        container:update()
    end

    function self:keypressed( _, scancode )
        love.mouse.setVisible( false )

        if scancode == 'left' then
            container:command( 'left' )
        elseif scancode == 'right' then
            container:command( 'right' )
        elseif scancode == 'return' then
            container:command( 'activate' )
        end

        if scancode == 'f1' then
            debug = not debug
        end
    end

    function self:mousemoved()
        love.mouse.setVisible( true )
    end

    function self:mousereleased()
        container:command( 'activate' )
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
