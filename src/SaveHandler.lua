---
-- @module SaveHandler
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' );
local Compressor = require( 'src.util.Compressor' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SaveHandler = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SAVE_FOLDER = 'saves'
local COMPRESSED_SAVE = 'compressed.data'
local VERSION_FILE = 'version.data'

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Takes care of transforming strings to numbers if possible.
-- @param value (mixed) The value to check.
-- @return      (mixed) The converted value.
--
local function convertStrings( value )
    local keysToReplace = {};

    for k, v in pairs( value ) do
        if tonumber( k ) then
            keysToReplace[#keysToReplace + 1] = k;
        end

        if type( v ) == 'table' then
            convertStrings( v );
        elseif tonumber( v ) then
            value[k] = tonumber( v );
        end
    end

    -- If the key can be transformed into a number delete the original
    -- key-value pair and store the value with the numerical key.
    for _, k in ipairs( keysToReplace ) do
        local v = value[k];
        value[k] = nil;
        value[tonumber(k)] = v;
    end

    return value;
end

---
-- Creates a file containing only the version string.
-- @string dir     The directory to store the version file in.
-- @table  version A table containing the version field.
--
local function createVersionFile( dir, version )
    Compressor.save( version, dir .. '/' .. VERSION_FILE )
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function SaveHandler.save( t, name )
    Log.print( 'Created savegame: ' .. name, 'SaveHandler' )

    -- Create the saves folder it doesn't exist already.
    if not love.filesystem.exists( SAVE_FOLDER ) then
        love.filesystem.createDirectory( SAVE_FOLDER )
    end

    -- Create a folder with the name for this specific savegame.
    local folder = SAVE_FOLDER .. '/' .. name
    love.filesystem.createDirectory( folder )

    createVersionFile( folder, { version = getVersion() })

    -- Save compressed file.
    Compressor.save( t, folder .. '/' .. COMPRESSED_SAVE )
end

function SaveHandler.load( path )
    return convertStrings( Compressor.load( path .. '/' .. COMPRESSED_SAVE ))
end

function SaveHandler.loadVersion( path )
    return Compressor.load( path .. '/' .. VERSION_FILE ).version
end

function SaveHandler.getSaveFolder()
    return SAVE_FOLDER
end

return SaveHandler;
