local Screen = require( 'lib.screenmanager.Screen' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Button = require( 'src.ui.elements.Button' );
local HorizontalList = require( 'src.ui.elements.HorizontalList' );
local SaveHandler = require( 'src.SaveHandler' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SplashScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local VERSION_STRING = string.format( 'WIP - Version: %s ', getVersion() );
local COPYRIGHT_STRING = ' © Robert Machmer, 2016-2017. All rights reserved.';

local TITLE_POSITION = 2;
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

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function SplashScreen.new()
    local self = Screen.new();

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local title;
    local buttonList;
    local debug;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function createTitle()
        local font = TexturePacks.getFont()
        title = love.graphics.newText( font:get() );
        for i, line in ipairs( TITLE_STRING ) do
            local coloredtext = {};
            for w in string.gmatch( line, '.' ) do
                if w == '@' then
                    coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_1' )
                    coloredtext[#coloredtext + 1] = 'O';
                elseif w == '!' then
                    coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_2' )
                    coloredtext[#coloredtext + 1] = w;
                else
                    coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_3' )
                    coloredtext[#coloredtext + 1] = w;
                end
                title:add( coloredtext, 0, i * font:get():getHeight() )
            end
        end
    end

    local function drawInfo()
        local font = TexturePacks.getFont()
        local sw, sh = love.graphics.getDimensions();
        TexturePacks.setColor( 'ui_text_dim' )
        love.graphics.print( VERSION_STRING, sw - font:measureWidth( VERSION_STRING ), sh - font:getGlyphHeight() )
        love.graphics.print( COPYRIGHT_STRING, 0, sh - font:getGlyphHeight() )
        TexturePacks.resetColor()
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

    local function startNewGame()
        ScreenManager.switch( 'gamescreen' );
    end

    local function loadPreviousGame()
        if SaveHandler.exists() then
            local save = SaveHandler.load();

            if save.gameversion == getVersion() then
                ScreenManager.switch( 'combat', save );
            end
        end
    end

    local function openOptions()
        ScreenManager.switch( 'options' );
    end

    local function exitGame()
        love.event.quit();
    end

    local function createButtons()
        buttonList = HorizontalList.new( love.graphics.getWidth() * 0.5, 30 * 16, 12 * 8, 16 );
        buttonList:addElement( Button.new( 'ui_main_menu_new_game', startNewGame ));
        buttonList:addElement( Button.new( 'ui_main_menu_load_game', loadPreviousGame ));
        buttonList:addElement( Button.new( 'ui_main_menu_options', openOptions ));
        buttonList:addElement( Button.new( 'ui_main_menu_exit', exitGame ));
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        createTitle();
        createButtons();

        -- Flush the LuaJIT cache to prevent memory leaks caused by cached
        -- upvalues and closures.
        -- @see https://github.com/LuaJIT/LuaJIT/issues/303
        jit.flush();

        collectgarbage( 'collect' );
    end

    function self:draw()
        local font = TexturePacks.getFont()
        font:use()
        love.graphics.draw( title, love.graphics.getWidth() * 0.5 - title:getWidth() * 0.5, TITLE_POSITION * font:getGlyphHeight() )

        buttonList:draw();

        drawInfo();
        drawDebugInfo();
    end

    function self:update()
        buttonList:update();
    end

    function self:keypressed( _, scancode )
        buttonList:keypressed( _, scancode );

        if scancode == 'f1' then
            debug = not debug;
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

return SplashScreen;
