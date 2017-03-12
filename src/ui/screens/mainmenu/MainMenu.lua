local Screen = require( 'lib.screenmanager.Screen' );
local ImageFont = require( 'src.ui.ImageFont' );
local MainButtonList = require( 'src.ui.screens.mainmenu.MainButtonList' );
local Translator = require( 'src.util.Translator' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SplashScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local VERSION_STRING = string.format( 'WIP - Version: %s ', getVersion() );
local COPYRIGHT_STRING = ' © Robert Machmer, 2016-2017. All rights reserved.';
local DEFAULT_LOCALE = 'en_EN';
local COLORS = require( 'src.constants.Colors' );
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
        title = love.graphics.newText( ImageFont.getFont() );
        for i, line in ipairs( TITLE_STRING ) do
            local coloredtext = {};
            for w in string.gmatch( line, '.' ) do
                if w == '@' then
                    coloredtext[#coloredtext + 1] = COLORS.DB18;
                    coloredtext[#coloredtext + 1] = 'O';
                elseif w == '!' then
                    coloredtext[#coloredtext + 1] = COLORS.DB17;
                    coloredtext[#coloredtext + 1] = w;
                else
                    coloredtext[#coloredtext + 1] = COLORS.DB17;
                    coloredtext[#coloredtext + 1] = w;
                end
                title:add( coloredtext, 0, i * ImageFont:getFont():getHeight() );
            end
        end
    end

    local function drawInfo()
        local sw, sh = love.graphics.getDimensions();
        love.graphics.setColor( COLORS.DB01 );
        love.graphics.print( VERSION_STRING, sw - ImageFont.measureWidth( VERSION_STRING ), sh - ImageFont.getGlyphHeight() );
        love.graphics.print( COPYRIGHT_STRING, 0, sh - ImageFont.getGlyphHeight() );
        love.graphics.setColor( 255, 255, 255 );
    end

    local function drawDebugInfo()
        if debug then
            love.graphics.setColor( COLORS.DB01 );
            love.graphics.print( love.timer.getFPS() .. ' FPS', ImageFont.getGlyphWidth(), ImageFont.getGlyphWidth() );
            love.graphics.print( math.floor( collectgarbage( 'count' )) .. ' kb', ImageFont.getGlyphWidth(), ImageFont.getGlyphWidth() + ImageFont.getGlyphHeight() );
            love.graphics.setColor( 255, 255, 255 );
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        Translator.init( DEFAULT_LOCALE );

        ImageFont.set();

        createTitle();

        buttonList = MainButtonList.new();
        buttonList:init();

        collectgarbage( 'collect' );
    end

    function self:draw()
        love.graphics.draw( title, love.graphics.getWidth() * 0.5 - title:getWidth() * 0.5, 100 );

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
