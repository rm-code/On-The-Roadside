local Screen = require( 'lib.screenmanager.Screen' );
local Translator = require( 'src.util.Translator' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UITextButton = require( 'src.ui.elements.UITextButton' )
local UISelectField = require( 'src.ui.elements.UISelectField' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local OptionsScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

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

local BUTTON_LIST_WIDTH = 20
local BUTTON_LIST_Y = 20

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function OptionsScreen.new()
    local self = Screen.new();

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local title;
    local buttonList
    local font
    local footer

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

    local function drawTitle()
        local cx, _ = GridHelper.centerElement( GridHelper.pixelsToGrid( title:getWidth(), title:getHeight() * #TITLE_STRING ))
        local tw, _ = TexturePacks.getTileDimensions()
        love.graphics.draw( title, cx * tw, TITLE_POSITION * TexturePacks.getFont():getGlyphHeight() )
    end


    local function createLanguageOption( lx, ly, index )
        local listOfValues = {
            { displayTextID = Translator.getText( 'ui_lang_eng' ), value = 'en_EN' },
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

        local field = UISelectField.new( lx, ly, 0, index, BUTTON_LIST_WIDTH, 1 )
        field:init( Translator.getText( 'ui_lang' ), listOfValues, callback, default )
        return field
    end

    local function createFullscreenOption( lx, ly, index )
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

        local field = UISelectField.new( lx, ly, 0, index, BUTTON_LIST_WIDTH, 1 )
        field:init( Translator.getText( 'ui_fullscreen' ), listOfValues, callback, default )
        return field
    end

    local function createTexturePackOption( lx, ly, index )
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

        local field = UISelectField.new( lx, ly, 0, index, BUTTON_LIST_WIDTH, 1 )
        field:init( Translator.getText( 'ui_texturepack' ), listOfValues, callback, default )
        return field
    end

    local function createBackButton( lx, ly, index )
        local function callback()
            ScreenManager.switch( 'mainmenu' );
        end
        local button = UITextButton.new( lx, ly, 0, index, BUTTON_LIST_WIDTH, 1 )
        button:init( Translator.getText( 'ui_back' ), callback )
        return button
    end

    local function createButtons()
        local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
        local ly = BUTTON_LIST_Y

        buttonList = UIVerticalList.new( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

        buttonList:addChild(    createLanguageOption( lx, ly, 1 ))
        buttonList:addChild(  createFullscreenOption( lx, ly, 2 ))
        buttonList:addChild( createTexturePackOption( lx, ly, 3 ))
        buttonList:addChild(        createBackButton( lx, ly, 4 ))
    end


    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        font = TexturePacks.getFont()

        createTitle();
        createButtons()

        footer = UICopyrightFooter.new()
    end

    function self:update()
        font = TexturePacks.getFont()
        buttonList:update()
    end

    function self:draw()
        font:use()
        drawTitle()
        buttonList:draw()

        footer:draw()
    end

    function self:keypressed( key, scancode )
        if scancode == 'escape' then
            ScreenManager.switch( 'mainmenu' );
        end
        buttonList:keypressed( key, scancode )
    end

    function self:mousereleased()
        buttonList:mousereleased()
    end

    function self:mousemoved()
        buttonList:mousemoved()
    end

    function self:resize( _, _ )
        local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
        local ly = BUTTON_LIST_Y

        buttonList:setOrigin( lx, ly )
    end

    return self;
end

return OptionsScreen;
