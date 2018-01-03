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
    version = 5,
    general = {
        fullscreen = true,
        locale = 'en_EN',
        mapeditor = false,
        texturepack = 'default',
        mousepanning = false,
        invertedMessageLog = false,
    },
    controls = {
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
        ['left']   = 'pan_camera_left',
        ['right']  = 'pan_camera_right',
        ['up']     = 'pan_camera_up',
        ['down']   = 'pan_camera_down'
    }
}

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
-- Loads the settings from the file.
--
function Settings.load()
    -- Create settings file if it doesn't exist yet.
    if not love.filesystem.isFile( FILE_NAME ) then
        create()
    elseif Compressor.load( FILE_NAME ).version ~= DEFAULT_SETTINGS.version then
        Log.warn( 'Detected outdated settings file => Replacing with default settings!', 'Settings' )
        create()
    end

    settings = Compressor.load( FILE_NAME )
end

---
-- Maps a scancode to a control action.
--
function Settings.mapInput( scancode )
    return settings.controls[scancode]
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

function Settings.getKeybinding( saction )
    for scancode, action in pairs( settings.controls ) do
        if action == saction then
            return love.keyboard.getKeyFromScancode( scancode )
        end
    end
    return 'unassigned'
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
    for section, content in pairs( oldSettings ) do
        if type( content ) == 'table' then
            for key, value in pairs( content ) do
                if settings[section][key] ~= value then
                    return true
                end
            end
        else
            if settings[section] ~= content then
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

function Settings.setKeybinding( scancode, saction )
    for oldscancode, action in pairs( settings.controls ) do
        if action == saction then
            settings.controls[oldscancode] = nil
            settings.controls[scancode] = action
            return
        end
    end
end

return Settings
