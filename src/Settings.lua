---
-- @module Settings
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Compressor = require( 'src.util.Compressor' )
local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Settings = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FILE_NAME = 'settings.otr'
local DEFAULT_SETTINGS = {
    version = 15,
    general = {
        fullscreen = true,
        locale = 'en_EN',
        mapeditor = true,
        texturepack = 'default',
        mousepanning = false,
        invertedMessageLog = false,
    },
    controls = {
        base = {
            ['i']      = 'open_inventory_screen',
            ['s']      = 'open_shop_screen',
        },
        combat = {
            ['x']      = 'action_stand',
            ['c']      = 'action_crouch',
            ['v']      = 'action_prone',
            ['r']      = 'action_reload_weapon',
            ['.']      = 'next_weapon_mode',
            [',']      = 'prev_weapon_mode',
            ['m']      = 'movement_mode',
            ['a']      = 'attack_mode',
            ['e']      = 'interaction_mode',
            ['tab']    = 'next_character',
            ['lshift'] = 'prev_character',
            ['return'] = 'end_turn',
            ['i']      = 'open_inventory_screen',
            ['h']      = 'open_health_screen',
            ['f1']     = 'center_camera',
            ['left']   = 'pan_camera_left',
            ['right']  = 'pan_camera_right',
            ['up']     = 'pan_camera_up',
            ['down']   = 'pan_camera_down'
        },
        inventory = {
            ['lshift'] = 'drag_item_stack',
            ['lctrl']  = 'split_item_stack'
        },
        prefabeditor = {
            [']']      = 'increase_tool_size',
            ['/']      = 'decrease_tool_size',
            ['d']      = 'mode_draw',
            ['e']      = 'mode_erase',
            ['f']      = 'mode_fill',
            ['h']      = 'hide_worldobjects',
            ['left']   = 'pan_camera_left',
            ['right']  = 'pan_camera_right',
            ['up']     = 'pan_camera_up',
            ['down']   = 'pan_camera_down'
        }
    }
}

local WARNING_TEXT = 'Replacing outdated settings file (v%d) with current default settings (v%d)!'
local UNASSIGNED_SCANCODE = 'unassigned'

Settings.INPUTLAYOUTS = {}
Settings.INPUTLAYOUTS.BASE = 'base'
Settings.INPUTLAYOUTS.COMBAT = 'combat'
Settings.INPUTLAYOUTS.INVENTORY = 'inventory'
Settings.INPUTLAYOUTS.PREFAB_EDITOR = 'prefabeditor'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local settings

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Uses the default settings to create a save file on the harddisk.
--
local function create()
    settings = DEFAULT_SETTINGS
    Settings.save()
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Saves the settings to a file and resets the changed variable.
--
function Settings.save()
    Compressor.save( settings, FILE_NAME )
end

---
-- Tries to load a settings file. If the file doesn't exist already, it will be
-- created. If the loaded settings file has an outdated version, it will be
-- replaced with the current default settings.
--
function Settings.load()
    -- Create settings file if it doesn't exist yet.
    if not love.filesystem.getInfo( FILE_NAME, 'file' ) then
        create()
    end

    -- Load current settings.
    settings = Compressor.load( FILE_NAME )

    -- Replace settings if we find an outdated version.
    if settings.version ~= DEFAULT_SETTINGS.version then
        Log.warn( string.format( WARNING_TEXT, settings.version, DEFAULT_SETTINGS.version ), 'Settings' )

        -- Create and load the new settings file.
        create()
        settings = Compressor.load( FILE_NAME )
    end

    Log.info( string.format( 'Loaded game settings (v%d)', settings.version ), 'Settings' )
end

---
-- Maps a scancode to a control action.
--
function Settings.mapInput( mode, scancode )
    return settings.controls[mode][scancode]
end

---
-- Maps an action to a keypress.
--
function Settings.mapAction( mode, actionToMap )
    for scancode, action in pairs( settings.controls[mode] ) do
        if action == actionToMap then
            return scancode
        end
    end
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function Settings.getFullscreen()
    return settings.general.fullscreen
end

function Settings.getIngameEditor()
    return settings.general.mapeditor
end

function Settings.getKeybinding( mode, saction )
    for scancode, action in pairs( settings.controls[mode] ) do
        if action == saction then
            return love.keyboard.getKeyFromScancode( scancode )
        end
    end
    return UNASSIGNED_SCANCODE
end

function Settings.getLocale()
    return settings.general.locale
end

function Settings.getMousePanning()
    return settings.general.mousepanning
end

function Settings.getInvertedMessageLog()
    return settings.general.invertedMessageLog
end

function Settings.getTexturepack()
    return settings.general.texturepack
end

---
-- Compares the current settings to the old settings and checks if any of the
-- values have changed.
-- @treturn boolean True if one or more values have changed.
--
function Settings.hasChanged()
    local oldSettings = Compressor.load( FILE_NAME )

    for section, content in pairs( oldSettings.general ) do
        if settings.general[section] ~= content then
            return true
        end
    end

    for layout, content in pairs( oldSettings.controls ) do
        for key, value in pairs( content ) do
            if settings.controls[layout][key] ~= value then
                return true
            end
        end
    end

    return false
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function Settings.setFullscreen( nfullscreen )
    settings.general.fullscreen = nfullscreen
end

function Settings.setIngameEditor( mapeditor )
    settings.general.mapeditor = mapeditor
end

function Settings.setLocale( nlocale )
    settings.general.locale = nlocale
end

function Settings.setMousePanning( mousepanning )
    settings.general.mousepanning = mousepanning
end

function Settings.setInvertedMessageLog( invertedMessageLog )
    settings.general.invertedMessageLog = invertedMessageLog
end

function Settings.setTexturepack( ntexturepack )
    settings.general.texturepack = ntexturepack
end

function Settings.setKeybinding( mode, scancode, saction )
    -- If the action is not assigned to a scancode yet we can set it directly.
    if Settings.getKeybinding( mode, saction ) == UNASSIGNED_SCANCODE then
        settings.controls[mode][scancode] = saction
        return
    end

    -- If the action is already mapped to a scancode, we have to remove the old
    -- mapping (or else both keys would work for the same action), before we can
    -- assign the new one.
    for oldscancode, action in pairs( settings.controls[mode] ) do
        if action == saction then
            settings.controls[mode][oldscancode] = nil
            settings.controls[mode][scancode] = action
            return
        end
    end
end

return Settings
