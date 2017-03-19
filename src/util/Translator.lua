local Log = require( 'src.util.Log' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Translator = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MISSING_TRANSLATION_ERROR = 'Translation for locale %s and ID %s doesn\'t exist. Falling back to default locale.';
local MISSING_ID_ERROR = 'TEXT_ERROR <%s>';
local LOCALE_ERROR = 'The selected locale %s doesn\'t exist. Falling back to default locale.';
local TEMPLATE_DIRECTORY  = 'res/text/';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local locales = {};
local locale;
local defaultLocale;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Loads the actual translation files and copies them into the locales table.
-- @param path (string) The subfolder to load from.
--
local function loadAdditionalText( path )
    local status, loaded = pcall( love.filesystem.load, path );
    if not status then
        Log.warn( 'Can not load translation file from ' .. path );
    else
        local template = loaded();

        -- Load table or create a new one.
        locales[template.identifier] = locales[template.identifier] or {};

        -- Copy translations to the main locale.
        for i, v in pairs( template.strings ) do
            locales[template.identifier][i] = v;
        end
    end
end

---
-- Searches the template directory for subfolders and tries to load the
-- translation files from there.
-- @param dir (string) The template directory to search through.
--
local function load( dir )
    local subdirectories = love.filesystem.getDirectoryItems( dir );
    for i, subdir in ipairs( subdirectories ) do
        local path = dir .. subdir .. '/';
        if love.filesystem.isDirectory( path ) then
            local files = love.filesystem.getDirectoryItems( path );

            -- Loads all the other text files for this locale.
            for _, file in ipairs( files ) do
                loadAdditionalText( path .. file );
            end
            Log.debug( string.format( '  %d. %s', i, subdir ));
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Initialises the Translator, by loading the translation files and setting the
-- default locale. It produces an error if the default locale doesn't exist.
-- @param nlocale (string) The identifier for the default locale (e.g. en_EN)
--
function Translator.init( nlocale )
    Log.debug( 'Load language files:' );
    load( TEMPLATE_DIRECTORY );

    -- Set the default locale and make it the active locale.
    -- The default locale will be used as a fallback.
    assert( locales[nlocale], string.format( 'The selected locale %s doesn\'t exist.', nlocale ));
    locale = nlocale;
    defaultLocale = nlocale;
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Gets the current locale.
-- @return (string) The identifier of the current locale (e.g. en_EN).
--
function Translator.getLocale()
    return locale;
end

---
-- Gets the text for the specified id from the active locale.
-- If the id can't be found, the function tries to fall back to the default locale.
-- @param  id (string) The id of the text to get.
-- @return    (string) The identifier of the current locale (e.g. en_EN).
--
function Translator.getText( id )
    -- If the id can't be found in the current locale try to use the default one.
    if not locales[locale][id] then
        Log.warn( string.format( MISSING_TRANSLATION_ERROR, locale, id ), 'Translator' );

        -- If the id also doesn't exist in the default locale return an error string.
        if not locales[defaultLocale][id] then
            Log.warn( string.format( MISSING_ID_ERROR, id ), 'Translator' );
            return string.format( MISSING_ID_ERROR, id );
        end

        return locales[defaultLocale][id];
    end

    return locales[locale][id];
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets the locale. If the new locale doesn't exist it prints a warning to the
-- console and falls back to the default locale.
-- @param nlocale (string) The identifier for the new locale (e.g. en_EN)
--
function Translator.setLocale( nlocale )
    if not locales[nlocale] then
        Log.warn( string.format( LOCALE_ERROR, nlocale ), 'Translator' );
        locale = defaultLocale;
        return;
    end

    locale = nlocale;
end

return Translator;
