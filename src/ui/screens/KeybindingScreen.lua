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
local UIMenuTitle = require( 'src.ui.elements.UIMenuTitle' )
local UIPaginatedList = require( 'src.ui.elements.lists.UIPaginatedList' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local KeybindingScreen = Screen:subclass( 'KeybindingScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TITLE_POSITION = 2
local BUTTON_LIST_WIDTH = 25
local BUTTON_LIST_HEIGHT = 15
local BUTTON_LIST_Y = 20

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function createKeybinding( mode, action )
    -- The function to call when the button is activated.
    local function callback()
        ScreenManager.push( 'keybindingmodal', mode, action )
    end

    -- Get the text representation for each key and a proper name for the action.
    local keyText = Settings.getKeybinding( mode, action )
    local actionText = string.format( '[%s] %s:', mode, Translator.getText( action ))

    -- Pad the action text with whitespace and place the key text at the end.
    -- This allows us to align the action name on the left and the key on the
    -- right. The width is determined by the button list's width which is
    -- multiplied by two because a character in the font is half the size of
    -- a grid space.
    local text = Util.rightPadString( actionText, BUTTON_LIST_WIDTH * 2 - #keyText, ' ' ) .. keyText

    -- Create the UIButton.
    return UIButton( 0, 0, 0, 0, BUTTON_LIST_WIDTH, 1, callback, text, 'left' )
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
-- @tparam  number   lx The parent's absolute coordinates along the x-axis.
-- @tparam  number   ly The parent's absolute coordinates along the y-axis.
-- @treturn UIButton    The newly created UIButton.
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
-- @tparam  number   lx The parent's absolute coordinates along the x-axis.
-- @tparam  number   ly The parent's absolute coordinates along the y-axis.
-- @treturn UIButton    The newly created UIButton.
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
-- Creates a sequence containing all the keybinding buttons.
-- @treturn table A sequence containing the UIButtons for the keybinding list.
--
local function getKeyButtonList()
    return {
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'action_stand' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'action_crouch' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'action_prone' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'action_reload_weapon' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'next_weapon_mode' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'prev_weapon_mode' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'movement_mode' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'attack_mode' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'interaction_mode' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'next_character' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'prev_character' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'end_turn' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'open_inventory_screen' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'open_health_screen' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'center_camera' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'pan_camera_left' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'pan_camera_right' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'pan_camera_up' ),
        createKeybinding( Settings.INPUTLAYOUTS.COMBAT, 'pan_camera_down' ),

        createKeybinding( Settings.INPUTLAYOUTS.INVENTORY, 'drag_item_stack' ),
        createKeybinding( Settings.INPUTLAYOUTS.INVENTORY, 'split_item_stack' ),

        createKeybinding( Settings.INPUTLAYOUTS.BASE, 'open_inventory_screen' ),
        createKeybinding( Settings.INPUTLAYOUTS.BASE, 'open_shop_screen' ),

        createKeybinding( Settings.INPUTLAYOUTS.PREFAB_EDITOR, 'increase_tool_size' ),
        createKeybinding( Settings.INPUTLAYOUTS.PREFAB_EDITOR, 'decrease_tool_size' ),
        createKeybinding( Settings.INPUTLAYOUTS.PREFAB_EDITOR, 'mode_draw' ),
        createKeybinding( Settings.INPUTLAYOUTS.PREFAB_EDITOR, 'mode_erase' ),
        createKeybinding( Settings.INPUTLAYOUTS.PREFAB_EDITOR, 'mode_fill' ),
        createKeybinding( Settings.INPUTLAYOUTS.PREFAB_EDITOR, 'hide_worldobjects' ),
        createKeybinding( Settings.INPUTLAYOUTS.PREFAB_EDITOR, 'pan_camera_left' ),
        createKeybinding( Settings.INPUTLAYOUTS.PREFAB_EDITOR, 'pan_camera_right' ),
        createKeybinding( Settings.INPUTLAYOUTS.PREFAB_EDITOR, 'pan_camera_up' ),
        createKeybinding( Settings.INPUTLAYOUTS.PREFAB_EDITOR, 'pan_camera_down' ),
    }
end

---
-- Creates a vertical list containing all the ui elements.
--
local function createPaginatedKeybindingList()
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
    local ly = BUTTON_LIST_Y
    local buttonList = UIPaginatedList( lx, ly, 0, 0, BUTTON_LIST_WIDTH, BUTTON_LIST_HEIGHT )

    buttonList:setItems( getKeyButtonList() )

    return buttonList
end

local function createButtonList()
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
    local ly = BUTTON_LIST_Y + BUTTON_LIST_HEIGHT + 1

    local buttonList = UIVerticalList( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

    buttonList:addChild( createApplyButton( lx, ly ))
    buttonList:addChild(  createBackButton( lx, ly ))

    return buttonList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function KeybindingScreen:initialize()
    self.container = UIContainer()

    self.paginatedList = createPaginatedKeybindingList()
    self.buttonList = createButtonList()

    self.container:register( self.paginatedList )
    self.container:register( self.buttonList )

    self.footer = UICopyrightFooter()

    self.title = UIMenuTitle( Translator.getText( 'ui_title_controls' ), TITLE_POSITION )
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
    self.paginatedList:draw()
    self.buttonList:draw()

    self.footer:draw()
    self.title:draw()
end

---
-- Handle keypressed events.
--
function KeybindingScreen:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'escape' then
        close()
    end

    if scancode == 'tab' then
        self.container:next()
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
        local scancode, mode, action = ...
        Settings.setKeybinding( mode, scancode, action )
        self.paginatedList:setItems( getKeyButtonList() )
    end
end

function KeybindingScreen:resize( _, _ )
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )

    self.paginatedList:setOrigin( lx, BUTTON_LIST_Y )
    self.buttonList:setOrigin( lx, BUTTON_LIST_Y + BUTTON_LIST_HEIGHT + 1 )
end

return KeybindingScreen
