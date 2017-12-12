---
-- @module KeybindingScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )
local Settings = require( 'src.Settings' )
local Translator = require( 'src.util.Translator' )
local GridHelper = require( 'src.util.GridHelper' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local UIButton = require( 'src.ui.elements.UIButton' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local Util = require( 'src.util.Util' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local KeybindingScreen = Screen:subclass( 'KeybindingScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local BUTTON_LIST_WIDTH = 20
local BUTTON_LIST_Y = 20

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function createKeybinding( lx, ly, action )
    -- The function to call when the button is activated.
    local function callback()
        ScreenManager.push( 'keybindingmodal', action )
    end

    -- Get the text representation for each key and a proper name for the action.
    local keyText = Settings.getKeybinding( action )
    local actionText = Translator.getText( action )

    -- Pad the action text with whitespace and place the key text at the end.
    -- This allows us to align the action name on the left and the key on the
    -- right. The width is determined by the button list's width which is
    -- multiplied by two because a character in the font is half the size of
    -- a grid space.
    local text = Util.rightPadString( actionText .. ':', BUTTON_LIST_WIDTH * 2 - #keyText, ' ' ) .. keyText

    -- Create the UIButton.
    return UIButton( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, callback, text, 'left' )
end

---
-- Applies the settings and saves them to a file.
--
local function applySettings()
    Settings.save()
    ScreenManager.push( 'information', Translator.getText( 'ui_applied_settings' ))
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
-- Closes the OptionsScreen and displays a confirmation dialog if any
-- settings have been changed.
--
local function close()
    if Settings.hasChanged() then
        local function confirm()
            ScreenManager.switch( 'options' )
        end
        local function cancel()
            ScreenManager.pop()
        end
        ScreenManager.push( 'confirm', Translator.getText( 'ui_unsaved_changes' ), confirm, cancel )
    else
        ScreenManager.switch( 'options' )
    end
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
    buttonList:addChild(  createKeybinding( lx, ly, 'action_stand' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'action_crouch' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'action_prone' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'action_reload_weapon' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'next_weapon_mode' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'prev_weapon_mode' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'movement_mode' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'attack_mode' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'interaction_mode' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'next_character' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'prev_character' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'end_turn' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'open_inventory_screen' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'open_health_screen' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'pan_camera_left' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'pan_camera_right' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'pan_camera_up' ))
    buttonList:addChild(  createKeybinding( lx, ly, 'pan_camera_down' ))
    buttonList:addChild( createApplyButton( lx, ly ))
    buttonList:addChild(  createBackButton( lx, ly ))

    return buttonList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function KeybindingScreen:initialize()
    self.buttonList = createUIList()

    self.container = UIContainer()
    self.container:register( self.buttonList )

    self.footer = UICopyrightFooter()
end

---
-- Updates the OptionsScreen.
--
function KeybindingScreen:update()
    self.container:update()
end

---
-- Draws the OptionsScreen.
--
function KeybindingScreen:draw()
    self.container:draw()
    self.footer:draw()
end

---
-- Handle keypressed events.
--
function KeybindingScreen:keypressed( _, scancode )
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

function KeybindingScreen:mousemoved()
    love.mouse.setVisible( true )
end

---
-- Handle mousereleased events.
--
function KeybindingScreen:mousereleased()
    self.container:mousecommand( 'activate' )
end

function KeybindingScreen:receive( event, ... )
    if event == 'CHANGED_KEYBINDING' then
        local action, scancode = ...
        Settings.setKeybinding( action, scancode )
        self:initialize()
    end
end

return KeybindingScreen
