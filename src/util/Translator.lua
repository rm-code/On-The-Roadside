local Log = require( 'src.util.Log' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Translator = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LOCALES = {};
local ERROR = 'TEXT_ERROR <%s>';
local TEMPLATE_DIRECTORY  = 'res/text/';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local locale;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

local function loadAdditionalText( path )
    local status, loaded = pcall( love.filesystem.load, path );
    if not status then
        Log.warn( 'Can not load translation file from ' .. path );
    else
        local template = loaded();

        -- Load table or create a new one.
        LOCALES[template.identifier] = LOCALES[template.identifier] or {};

        -- Copy translations to the main locale.
        for i, v in pairs( template.strings ) do
            LOCALES[template.identifier][i] = v;
        end
    end
end

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

function Translator.init( nlocale )
    locale = nlocale;

    Log.debug( 'Load language files:' );
    load( TEMPLATE_DIRECTORY );
end

function Translator.changeLocale( nlocale )
    locale = nlocale;
end

function Translator.getText( id )
    return LOCALES[locale][id] or string.format( ERROR, id );
end

return Translator;
