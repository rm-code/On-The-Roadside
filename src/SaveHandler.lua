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
local COMPRESSED_SAVE = 'game.data'
local VERSION_FILE = 'version.data'

local TEMP_FOLDER = SAVE_FOLDER .. '/_'
local PLAYER_FACTION_SAVE = 'tmp_faction.data'

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

---
-- Copies the current player faction to the harddisk as a temporary file.
-- This should only be used to copy and paste the player faction data between
-- different states.
-- @tparam table t The player faction data.
--
function SaveHandler.copyPlayerFaction( t )
    Log.info( 'Saving player faction...', 'SaveHandler' )

    -- Create the saves folder it doesn't exist already.
    if not love.filesystem.getInfo( TEMP_FOLDER ) then
        love.filesystem.createDirectory( TEMP_FOLDER )
    end

    Compressor.save( t, TEMP_FOLDER .. '/' .. PLAYER_FACTION_SAVE )
end

---
-- Loads the temporary player faction file from the harddisk.
-- This should only be used to copy and paste the player faction data between
-- different states.
--
function SaveHandler.pastePlayerFaction()
    return Compressor.load( TEMP_FOLDER .. '/' .. PLAYER_FACTION_SAVE )
end

function SaveHandler.getSaveFolder()
    return SAVE_FOLDER
end

return SaveHandler
