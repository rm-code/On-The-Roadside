---
-- The OptionsScreen module is a menu in which the player can customize certain
-- aspects of the game.
-- @module OptionsScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
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
local UIMenuTitle = require( 'src.ui.elements.UIMenuTitle' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local OptionsScreen = Screen:subclass( 'OptionsScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TITLE_POSITION = 2
local BUTTON_LIST_WIDTH = 20
local BUTTON_LIST_Y = 20

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

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
    Translator.setLocale( Settings.getLocale() )
    TexturePacks.setCurrent( Settings.getTexturepack() )
    love.window.setFullscreen( Settings.getFullscreen() )
    ScreenManager.push( 'information', Translator.getText( 'ui_applied_settings' ))
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
    local listOfValues = {}

    for localeID, _ in pairs( Translator.getLocales() ) do
        listOfValues[#listOfValues + 1] = { displayTextID = Translator.getText( localeID ), value = localeID }
    end

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
-- Creates a UISelectField which allows the user to activate mouse panning.
-- @tparam  number        lx    The parent's absolute coordinates along the x-axis.
-- @tparam  number        ly    The parent's absolute coordinates along the y-axis.
-- @treturn UISelectField       The newly created UISelectField.
--
local function createInvertMessageLogOption( lx, ly )
    -- The list of values to display.
    local listOfValues = {
        { displayTextID = Translator.getText( 'ui_on' ), value = true },
        { displayTextID = Translator.getText( 'ui_off' ), value = false }
    }

    -- The function to call when the value of the UISelectField changes.
    local function callback( val )
        Settings.setInvertedMessageLog( val )
    end

    -- Search the value corresponding to the currently selected option or
    -- take the first one and make it the current display value.
    local default = Settings.getInvertedMessageLog()
    for i, option in ipairs( listOfValues ) do
        if option.value == default then
            default = i
        end
    end

    -- Create the UISelectField.
    return UISelectField( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, Translator.getText( 'ui_settings_invert_messagelog' ), listOfValues, callback, default )
end
---
-- Creates a UISelectField which allows the user to activate the ingame map editor.
-- @tparam  number        lx    The parent's absolute coordinates along the x-axis.
-- @tparam  number        ly    The parent's absolute coordinates along the y-axis.
-- @treturn UISelectField       The newly created UISelectField.
--
local function createIngameEditorOption( lx, ly )
    -- The list of values to display.
    local listOfValues = {
        { displayTextID = Translator.getText( 'ui_on' ), value = true },
        { displayTextID = Translator.getText( 'ui_off' ), value = false }
    }

    -- The function to call when the value of the UISelectField changes.
    local function callback( val )
        Settings.setIngameEditor( val )
    end

    -- Search the value corresponding to the currently selected option or
    -- take the first one and make it the current display value.
    local default = Settings.getIngameEditor()
    for i, option in ipairs( listOfValues ) do
        if option.value == default then
            default = i
        end
    end

    -- Create the UISelectField.
    return UISelectField( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, Translator.getText( 'ui_settings_ingame_editor' ), listOfValues, callback, default )
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
-- Creates a UISelectField which allows the user to activate mouse panning.
-- @tparam  number        lx    The parent's absolute coordinates along the x-axis.
-- @tparam  number        ly    The parent's absolute coordinates along the y-axis.
-- @treturn UISelectField       The newly created UISelectField.
--
local function createMousePanningOption( lx, ly )
    -- The list of values to display.
    local listOfValues = {
        { displayTextID = Translator.getText( 'ui_on' ), value = true },
        { displayTextID = Translator.getText( 'ui_off' ), value = false }
    }

    -- The function to call when the value of the UISelectField changes.
    local function callback( val )
        Settings.setMousePanning( val )
    end

    -- Search the value corresponding to the currently selected option or
    -- take the first one and make it the current display value.
    local default = Settings.getMousePanning()
    for i, option in ipairs( listOfValues ) do
        if option.value == default then
            default = i
        end
    end

    -- Create the UISelectField.
    return UISelectField( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, Translator.getText( 'ui_settings_mouse_panning' ), listOfValues, callback, default )
end

---
-- Creates a UISelectField which allows the user to switch to the keybinding screen.
-- @tparam  number   lx The parent's absolute coordinates along the x-axis.
-- @tparam  number   ly The parent's absolute coordinates along the y-axis.
-- @treturn UIButton    The newly created UIButton.
--
local function createKeybindingOption( lx, ly )
    -- The function to call when the button is activated.
    local function callback()
        ScreenManager.switch( 'keybindingeditor' )
    end

    -- Create the UIButton.
    return UIButton( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, callback, Translator.getText( 'ui_keybindings' ))
end

---
-- Creates a UIButton which opens the modding directory.
-- @tparam  number   lx The parent's absolute coordinates along the x-axis.
-- @tparam  number   ly The parent's absolute coordinates along the y-axis.
-- @treturn UIButton    The newly created UIButton.
--
local function createOpenModdingDirectoryOption( lx, ly )
    -- The function to call when the button is activated.
    local function callback()
        love.system.openURL( 'file://' .. love.filesystem.getSaveDirectory() )
    end

    -- Create the UIButton.
    return UIButton( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, callback, Translator.getText( 'ui_open_modding_dir' ))
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
    local buttonList = UIVerticalList( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

    -- Create the UIElements and add them to the list.
    buttonList:addChild(             createLanguageOption( lx, ly ))
    buttonList:addChild(           createFullscreenOption( lx, ly ))
    buttonList:addChild(     createInvertMessageLogOption( lx, ly ))
    buttonList:addChild(         createIngameEditorOption( lx, ly ))
    buttonList:addChild(          createTexturePackOption( lx, ly ))
    buttonList:addChild(         createMousePanningOption( lx, ly ))
    buttonList:addChild(           createKeybindingOption( lx, ly ))
    buttonList:addChild( createOpenModdingDirectoryOption( lx, ly ))
    buttonList:addChild(                createApplyButton( lx, ly ))
    buttonList:addChild(                 createBackButton( lx, ly ))

    return buttonList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initialises the OptionsScreen.
--
function OptionsScreen:initialize()
    Settings.load()

    self.title = UIMenuTitle( Translator.getText( 'ui_title_options' ), TITLE_POSITION )
    self.buttonList = createUIList()

    self.container = UIContainer()
    self.container:register( self.buttonList )

    self.footer = UICopyrightFooter()
end

---
-- Updates the OptionsScreen.
--
function OptionsScreen:update()
    self.container:update()
end

---
-- Draws the OptionsScreen.
--
function OptionsScreen:draw()
    self.title:draw()

    self.container:draw()

    self.footer:draw()
end

---
-- Handle keypressed events.
--
function OptionsScreen:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'escape' then
        close()
    end

    if scancode == 'up' then
        self.container:command( 'up' )
    elseif scancode == 'down' then
        self.container:command( 'down' )
    elseif scancode == 'left' then
        self.container:command( 'left' )
    elseif scancode == 'right' then
        self.container:command( 'right' )
    elseif scancode == 'return' then
        self.container:command( 'activate' )
    end
end

function OptionsScreen:mousemoved()
    love.mouse.setVisible( true )
end

---
-- Handle mousereleased events.
--
function OptionsScreen:mousereleased()
    self.container:mousecommand( 'activate' )
end

---
-- Handle resize events and update the position of the UIElements accordingly.
--
function OptionsScreen:resize( _, _ )
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
    local ly = BUTTON_LIST_Y

    self.buttonList:setOrigin( lx, ly )
end

return OptionsScreen
