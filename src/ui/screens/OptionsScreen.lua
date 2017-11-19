---
-- The OptionsScreen module is a menu in which the player can customize certain
-- aspects of the game.
-- @module OptionsScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local Translator = require( 'src.util.Translator' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local UISelectField = require( 'src.ui.elements.UISelectField' )
local GridHelper = require( 'src.util.GridHelper' )
local Settings = require( 'src.Settings' )
local UIContainer = require( 'src.ui.elements.UIContainer' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local OptionsScreen = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TITLE_POSITION = 2
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
    local self = Screen.new()

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local title
    local buttonList
    local font
    local footer
    local container

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Creates the ASCII title at the top of the page.
    --
    local function createTitle()
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

    ---
    -- Draws the ASCII title at the top of the page at a grid aligned position.
    --
    local function drawTitle()
        local cx, _ = GridHelper.centerElement( GridHelper.pixelsToGrid( title:getWidth(), title:getHeight() * #TITLE_STRING ))
        local tw, _ = TexturePacks.getTileDimensions()
        love.graphics.draw( title, cx * tw, TITLE_POSITION * TexturePacks.getFont():getGlyphHeight() )
    end

    ---
    -- Closes the OptionsScreen and displays a confirmation dialog if any
    -- settings have been changed.
    --
    local function close()
        if Settings.hasChanged() then
            local function confirm()
                ScreenManager.switch( 'mainmenu' )
            end
            local function cancel()
                ScreenManager.pop()
            end
            ScreenManager.push( 'confirm', Translator.getText( 'ui_unsaved_changes' ), confirm, cancel )
        else
            ScreenManager.switch( 'mainmenu' )
        end
    end

    ---
    -- Applies the settings and saves them to a file.
    --
    local function applySettings()
        Settings.save()
        Translator.init( Settings.getLocale() )
        TexturePacks.setCurrent( Settings.getTexturepack() )
        love.window.setFullscreen( Settings.getFullscreen() )
    end

    ---
    -- Creates a UISelectField which allows the user to change the game's
    -- language settings.
    -- @tparam  number        lx    The parent's absolute coordinates along the x-axis.
    -- @tparam  number        ly    The parent's absolute coordinates along the y-axis.
    -- @treturn UISelectField       The newly created UISelectField.
    --
    local function createLanguageOption( lx, ly )
        -- The list of values to display.
        local listOfValues = {
            { displayTextID = Translator.getText( 'ui_lang_eng' ), value = 'en_EN' }
        }

        -- The function to call when the value of the UISelectField changes.
        local function callback( val )
            Settings.setLocale( val )
        end

        -- Search the value corresponding to the currently selected option or
        -- take the first one and make it the current display value.
        local default = Settings.getLocale()
        for i, option in ipairs( listOfValues ) do
            if option.value == Translator.getLocale() then
                default = i
            end
        end

        -- Create the UISelectField.
        return UISelectField( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, Translator.getText( 'ui_lang' ), listOfValues, callback, default )
    end

    ---
    -- Creates a UISelectField which allows the user to change the game's
    -- fullscreen settings.
    -- @tparam  number        lx    The parent's absolute coordinates along the x-axis.
    -- @tparam  number        ly    The parent's absolute coordinates along the y-axis.
    -- @treturn UISelectField       The newly created UISelectField.
    --
    local function createFullscreenOption( lx, ly )
        -- The list of values to display.
        local listOfValues = {
            { displayTextID = Translator.getText( 'ui_on' ), value = true },
            { displayTextID = Translator.getText( 'ui_off' ), value = false }
        }

        -- The function to call when the value of the UISelectField changes.
        local function callback( val )
            Settings.setFullscreen( val )
        end

        -- Search the value corresponding to the currently selected option or
        -- take the first one and make it the current display value.
        local default = Settings.getFullscreen()
        for i, option in ipairs( listOfValues ) do
            if option.value == love.window.getFullscreen() then
                default = i
            end
        end

        -- Create the UISelectField.
        return UISelectField( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, Translator.getText( 'ui_fullscreen' ), listOfValues, callback, default )
    end

    ---
    -- Creates a UISelectField which allows the user to change the game's
    -- fullscreen settings.
    -- @tparam  number        lx    The parent's absolute coordinates along the x-axis.
    -- @tparam  number        ly    The parent's absolute coordinates along the y-axis.
    -- @treturn UISelectField       The newly created UISelectField.
    --
    local function createTexturePackOption( lx, ly )
        -- The list of values to display. We populate it with the TexturePacks
        -- we found in the game's directory.
        local listOfValues = {}
        local packs = TexturePacks.getTexturePacks()
        for name, _ in pairs( packs ) do
            listOfValues[#listOfValues + 1] = { displayTextID = name, value = name }
        end

        -- The function to call when the value of the UISelectField changes.
        local function callback( val )
            Settings.setTexturepack( val )
        end

        -- Search the value corresponding to the currently selected option or
        -- take the first one and make it the current display value.
        local default = Settings.getTexturepack()
        for i, option in ipairs( listOfValues ) do
            if option.value == TexturePacks.getName() then
                default = i
            end
        end

        -- Create the UISelectField.
        return UISelectField( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, Translator.getText( 'ui_texturepack' ), listOfValues, callback, default )
    end

    ---
    -- Creates a button which allows the user to apply the new settings.
    -- @tparam  number       lx    The parent's absolute coordinates along the x-axis.
    -- @tparam  number       ly    The parent's absolute coordinates along the y-axis.
    -- @treturn UIButton           The newly created UIButton.
    --
    local function createApplyButton( lx, ly )
        -- The function to call when the button is activated.
        local function callback()
            applySettings()
        end

        -- Create the UIButton.
        return UIButton( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, callback, Translator.getText( 'ui_apply' ))
    end

    ---
    -- Creates a button which allows the user to return to the main menu.
    -- @tparam  number       lx    The parent's absolute coordinates along the x-axis.
    -- @tparam  number       ly    The parent's absolute coordinates along the y-axis.
    -- @treturn UIButton           The newly created UIButton.
    --
    local function createBackButton( lx, ly )
        -- The function to call when the button is activated.
        local function callback()
            close()
        end

        -- Create the UIButton.
        return UIButton( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, callback, Translator.getText( 'ui_back' ))
    end

    ---
    -- Creates a vertical list containing all the ui elements.
    --
    local function createUIList()
        local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
        local ly = BUTTON_LIST_Y

        buttonList = UIVerticalList( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

        -- Create the UIElements and add them to the list.
        buttonList:addChild(    createLanguageOption( lx, ly ))
        buttonList:addChild(  createFullscreenOption( lx, ly ))
        buttonList:addChild( createTexturePackOption( lx, ly ))
        buttonList:addChild(       createApplyButton( lx, ly ))
        buttonList:addChild(        createBackButton( lx, ly ))
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Initialises the OptionsScreen.
    --
    function self:init()
        Settings.load()
        font = TexturePacks.getFont()

        createTitle()
        createUIList()

        container = UIContainer()
        container:register( buttonList )

        footer = UICopyrightFooter.new()
    end

    ---
    -- Updates the OptionsScreen.
    --
    function self:update()
        font = TexturePacks.getFont()
        buttonList:update()
    end

    ---
    -- Draws the OptionsScreen.
    --
    function self:draw()
        font:use()
        drawTitle()

        container:draw()

        footer:draw()
    end

    ---
    -- Handle keypressed events.
    --
    function self:keypressed( _, scancode )
        love.mouse.setVisible( false )

        if scancode == 'escape' then
            close()
        end

        if scancode == 'up' then
            container:command( 'up' )
        elseif scancode == 'down' then
            container:command( 'down' )
        elseif scancode == 'left' then
            container:command( 'left' )
        elseif scancode == 'right' then
            container:command( 'right' )
        elseif scancode == 'return' then
            container:command( 'activate' )
        end
    end

    function self:mousemoved()
        love.mouse.setVisible( true )
    end

    ---
    -- Handle mousereleased events.
    --
    function self:mousereleased()
        container:command( 'activate' )
    end

    ---
    -- Handle resize events and update the position of the UIElements accordingly.
    --
    function self:resize( _, _ )
        local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
        local ly = BUTTON_LIST_Y

        buttonList:setOrigin( lx, ly )
    end

    return self
end

return OptionsScreen
