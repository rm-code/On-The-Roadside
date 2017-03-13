local Screen = require( 'lib.screenmanager.Screen' );
local SelectField = require( 'src.ui.elements.SelectField' );
local Translator = require( 'src.util.Translator' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local ImageFont = require( 'src.ui.ImageFont' );
local VerticalList = require( 'src.ui.elements.VerticalList' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local OptionsScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FIELD_WIDTH = 300;
local COLORS = require( 'src.constants.Colors' );
local TITLE_STRING = {
    "  @@@@    @@@@@@@   @@@@@@@  @@@    @@@@    @@   @@    @@@@@  ",
    "@@@@@@@@  @@@@@@@@  @@@@@@@  @@@  @@@@@@@@  @@@  @@@  @@@@@@@ ",
    "@@!  @@@  @@!  @@@    @@!    @@!  @@!  @@@  @@!@ @@@  !@@     ",
    "!@!  @!@  !@!  @!@    !@!    !@!  !@!  @!@  !@!!@!@!  !@!     ",
    "@!@  !@!  @!@@!@!     @!!    !!@  @!@  !@!  @!@ !!@!  !!@@!!  ",
    "!@!  !!!  !!@!!!      !!!    !!!  !@!  !!!  !@!  !!!   !!@!!! ",
    "!!:  !!!  !!:         !!:    !!:  !!:  !!!  !!:  !!!       !:!",
    ":!:  !:!  :!:         :!:    :!:  :!:  !:!  :!:  !:!      !:! ",
    ":!:::!!:   ::          ::     ::  :!:::!!:   ::   ::  ::!:::: ",
    "  :!::      :           :      :    :!::      :    :   :::..  "
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function OptionsScreen.new()
    local self = Screen.new();

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local title;
    local verticalList;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function createTitle()
        title = love.graphics.newText( ImageFont.get() );
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
                title:add( coloredtext, 0, i * ImageFont:get():getHeight() );
            end
        end
    end

    local function createLanguageOption()
        local listOfValues = {
            { displayTextID = Translator.getText( 'ui_lang_eng' ), value = 'en_EN' },
            { displayTextID = Translator.getText( 'ui_lang_ger' ), value = 'de_DE' },
        }

        local function callback( val )
            Translator.setLocale( val );
        end

        return SelectField.new( Translator.getText( 'ui_lang' ), listOfValues, callback )
    end

    local function createFullscreenOption()
        local listOfValues = {
            { displayTextID = Translator.getText( 'ui_on' ), value = true },
            { displayTextID = Translator.getText( 'ui_off' ), value = false },
        }

        local function callback( val )
            love.window.setFullscreen( val );
        end

        return SelectField.new( Translator.getText( 'ui_fullscreen' ), listOfValues, callback );
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        createTitle();

        local x = love.graphics.getWidth() * 0.5 - FIELD_WIDTH * 0.5;
        local y = 20 * ImageFont.getGlyphHeight();
        verticalList = VerticalList.new( x, y, FIELD_WIDTH, ImageFont.getGlyphHeight() );
        verticalList:addElement(   createLanguageOption() );
        verticalList:addElement( createFullscreenOption() );
    end

    function self:update()
        verticalList:update();
    end

    function self:draw()
        love.graphics.draw( title, love.graphics.getWidth() * 0.5 - title:getWidth() * 0.5, 2 * ImageFont.getGlyphHeight() );
        verticalList:draw();
    end

    function self:keypressed( key, scancode )
        if scancode == 'escape' then
            ScreenManager.switch( 'mainmenu' );
        end
        verticalList:keypressed( key, scancode );
    end

    function self:mousereleased()
        verticalList:mousereleased();
    end

    function self:mousemoved()
        verticalList:mousemoved();
    end

    function self:resize( nw, _ )
        local x = nw * 0.5 - FIELD_WIDTH * 0.5;
        local y = 20 * ImageFont.getGlyphHeight();
        verticalList:setPosition( x, y );
    end

    return self;
end

return OptionsScreen;
