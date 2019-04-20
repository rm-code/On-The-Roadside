---
-- @module Translator
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Translator = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MISSING_TRANSLATION_ERROR = 'Translation for locale %s and ID %s doesn\'t exist. Falling back to default locale.'
local MISSING_ID_ERROR = 'TEXT_ERROR <%s>'
local LOCALE_ERROR = 'The selected locale %s doesn\'t exist. Falling back to default locale.'
local TEMPLATE_DIRECTORY  = 'res/text/'
local MODDING_DIRECTORY  = 'mods/language/'

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local locales = {}
local locale
local defaultLocale
local counter

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Loads the actual translation files and copies them into the locales table.
-- @tparam string path The subfolder to load from.
--
local function loadAdditionalText( path )
    local status, loaded = pcall( love.filesystem.load, path )
    if not status then
        Log.warn( 'Can not load translation file from ' .. path, 'Translator' )
    else
        local template = loaded()

        -- Load table or create a new one.
        locales[template.identifier] = template.strings

        counter = counter + 1
        Log.info( string.format( '  %d. %s', counter, template.identifier ), 'Translator' )
    end
end

---
-- Searches the template directory for subfolders and tries to load the
-- translation files from there.
-- @tparam string dir The template directory to search through.
--
local function load( dir )
    local directoryItems = love.filesystem.getDirectoryItems( dir )
    for _, item in ipairs( directoryItems ) do
        if love.filesystem.getInfo( dir .. item, 'file' ) then
            -- Loads the text file for this locale.
            loadAdditionalText( dir .. item )
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Initialises the Translator, by loading the translation files and setting the
-- default locale. It produces an error if the default locale doesn't exist.
-- @tparam string nlocale The identifier for the default locale (e.g. en_EN)
--
function Translator.init( nlocale )
    counter = 0

    Log.info( 'Load language files:', 'Translator' )
    load( TEMPLATE_DIRECTORY )
    load( MODDING_DIRECTORY )

    -- Set the default locale and make it the active locale.
    -- The default locale will be used as a fallback.
    assert( locales[nlocale], string.format( 'The selected locale %s doesn\'t exist.', nlocale ))
    locale = nlocale
    defaultLocale = nlocale
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Gets the current locale.
-- @treturn string The identifier of the current locale (e.g. en_EN).
--
function Translator.getLocale()
    return locale
end

---
-- Gets all locales.
-- @treturn table All loaded locales.
--
function Translator.getLocales()
    return locales
end

---
-- Gets the text for the specified id from the active locale.
-- If the id can't be found, the function tries to fall back to the default locale.
-- @tparam  string id The id of the text to get.
-- @treturn string    The identifier of the current locale (e.g. en_EN).
--
function Translator.getText( id )
    -- If the id can't be found in the current locale try to use the default one.
    if not locales[locale][id] then
        Log.warn( string.format( MISSING_TRANSLATION_ERROR, locale, id ), 'Translator' )

        -- If the id also doesn't exist in the default locale return an error string.
        if not locales[defaultLocale][id] then
            Log.warn( string.format( MISSING_ID_ERROR, id ), 'Translator' )
            locales[locale][id] = string.format( MISSING_ID_ERROR, id )
            return string.format( MISSING_ID_ERROR, id )
        end

        locales[locale][id] = locales[defaultLocale][id]
        return locales[defaultLocale][id]
    end

    return locales[locale][id]
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets the locale. If the new locale doesn't exist it prints a warning to the
-- console and falls back to the default locale.
-- @tparam string nlocale The identifier for the new locale (e.g. en_EN)
--
function Translator.setLocale( nlocale )
    if not locales[nlocale] then
        Log.warn( string.format( LOCALE_ERROR, nlocale ), 'Translator' )
        locale = defaultLocale
        return
    end

    locale = nlocale
end

return Translator
