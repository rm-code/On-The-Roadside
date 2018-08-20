---
-- @module SaveHandler
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Compressor = require( 'src.util.Compressor' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SaveHandler = {}

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
-- Creates a file containing only the version string.
-- @tparam string dir     The directory to store the version file in.
-- @tparam table  version A table containing the version field.
--
local function createVersionFile( dir, version )
    Compressor.save( version, dir .. '/' .. VERSION_FILE )
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function SaveHandler.save( t, name )
    Log.info( 'Created savegame: ' .. name, 'SaveHandler' )

    -- Create the saves folder it doesn't exist already.
    if not love.filesystem.getInfo( SAVE_FOLDER ) then
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
    return Compressor.load( path .. '/' .. COMPRESSED_SAVE )
end

function SaveHandler.loadVersion( path )
    local result, error = Compressor.load( path .. '/' .. VERSION_FILE )
    if not result then
        Log.warn( error, 'SaveHandler' )
        return '<undefined>'
    end
    return result.version
end

function SaveHandler.getSaveFolder()
    return SAVE_FOLDER
end

return SaveHandler
