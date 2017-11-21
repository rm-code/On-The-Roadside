---
-- @module Settings
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Bitser = require( 'lib.Bitser' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Settings = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FILE_NAME = 'settings.otr'
local DEFAULT_SETTINGS = {
    general = {
        fullscreen = true,
        locale = 'en_EN',
        texturepack = 'default'
    }
}

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local settings
local changed

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

---
-- Sets the changed variable to true if the new value differs from the old.
-- @tparam ... old The old value to check.
-- @tparam ... new The new value to check.
-- @tparam ...     The new value to apply.
local function changeValue( old, new )
    if old ~= new then
        changed = true
    end
    return new
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Saves the settings to a file and resets the changed variable.
--
function Settings.save()
    changed = false
    Bitser.dumpLoveFile( FILE_NAME, settings )
end

---
-- Loads the settings from the file.
--
function Settings.load()
    -- Create settings file if it doesn't exist yet.
    if not love.filesystem.isFile( FILE_NAME ) then
        create()
    end

    settings = Bitser.loadLoveFile( FILE_NAME )
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

function Settings.getLocale()
    return settings.general.locale
end


function Settings.getTexturepack()
    return settings.general.texturepack
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function Settings.setFullscreen( nfullscreen )
    settings.general.fullscreen = changeValue( settings.general.fullscreen, nfullscreen )
end

function Settings.setIngameEditor( mapeditor )
    settings.general.mapeditor = changeValue( settings.general.mapeditor, mapeditor )
end

function Settings.setLocale( nlocale )
    settings.general.locale = changeValue( settings.general.locale, nlocale )
end

function Settings.setTexturepack( ntexturepack )
    settings.general.texturepack = changeValue( settings.general.texturepack, ntexturepack )
end

function Settings.hasChanged()
    return changed
end

return Settings
