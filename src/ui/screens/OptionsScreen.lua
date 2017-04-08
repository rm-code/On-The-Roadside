local Screen = require( 'lib.screenmanager.Screen' );
local SelectField = require( 'src.ui.elements.SelectField' );
local Translator = require( 'src.util.Translator' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local VerticalList = require( 'src.ui.elements.VerticalList' );
local Button = require( 'src.ui.elements.Button' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local OptionsScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FIELD_WIDTH = 300;

local TITLE_POSITION = 2;
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
    local font

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function createTitle()
        title = love.graphics.newText( font:get() )
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

    local function createLanguageOption()
        local listOfValues = {
            { displayTextID = Translator.getText( 'ui_lang_eng' ), value = 'en_EN' },
            { displayTextID = Translator.getText( 'ui_lang_ger' ), value = 'de_DE' },
        }

        local function callback( val )
            Translator.setLocale( val );
        end

        local default = 1;
        for i, option in ipairs( listOfValues ) do
            if option.value == Translator.getLocale() then
                default = i;
            end
        end

        return SelectField.new( font, Translator.getText( 'ui_lang' ), listOfValues, callback, default )
    end

    local function createFullscreenOption()
        local listOfValues = {
            { displayTextID = Translator.getText( 'ui_on' ), value = true },
            { displayTextID = Translator.getText( 'ui_off' ), value = false },
        }

        local function callback( val )
            love.window.setFullscreen( val );
        end

        local default = 1;
        for i, option in ipairs( listOfValues ) do
            if option.value == love.window.getFullscreen() then
                default = i;
            end
        end

        return SelectField.new( font, Translator.getText( 'ui_fullscreen' ), listOfValues, callback, default )
    end

    local function createTexturePackOption()
        local listOfValues = {}

        local packs = TexturePacks.getTexturePacks()
        for name, _ in pairs( packs ) do
            listOfValues[#listOfValues + 1] = { displayTextID = name, value = name }
        end

        local function callback( val )
            TexturePacks.setCurrent( val )
        end

        local default = 1
        for i, option in ipairs( listOfValues ) do
            if option.value == TexturePacks.getName() then
                default = i
            end
        end

        return SelectField.new( font, Translator.getText( 'ui_texturepack' ), listOfValues, callback, default )
    end

    local function createBackButton()
        local function callback()
            ScreenManager.switch( 'mainmenu' );
        end
        return Button.new( 'ui_back', callback );
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        font = TexturePacks.getFont()

        createTitle();

        local x = love.graphics.getWidth() * 0.5 - FIELD_WIDTH * 0.5;
        local y = 20 * font:getGlyphHeight()
        verticalList = VerticalList.new( x, y, FIELD_WIDTH, font:getGlyphHeight() )
        verticalList:addElement(   createLanguageOption() );
        verticalList:addElement( createFullscreenOption() );
        verticalList:addElement( createTexturePackOption() )
        verticalList:addElement(       createBackButton() );
    end

    function self:update()
        font = TexturePacks.getFont()
        verticalList:update();
    end

    function self:draw()
        font:use()
        love.graphics.draw( title, love.graphics.getWidth() * 0.5 - title:getWidth() * 0.5, TITLE_POSITION * font:getGlyphHeight() )
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
        local y = 20 * font:getGlyphHeight()
        verticalList:setPosition( x, y );
    end

    return self;
end

return OptionsScreen;
