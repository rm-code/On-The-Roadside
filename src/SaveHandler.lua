---
-- This module handles the saving and loading of savegames and also offers
-- functions to save and load temporary data of the player's faction which
-- can be used to pass around the player's faction between different states.
--
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

local VERSION_FILE_WARNING = 'Can not load a version file from "%s"'
local SAVE_FILE_WARNING = 'Can not load a save file from "%s"'
local VERSION_MISMATCH_WARNING = 'Save file version (%s) doesn\'t match the current game version (%s).'

local TEMP_FOLDER = 'tmp'
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

---
-- Creates a new savegame based on the provided data table and the name string.
-- @tparam table  t    The data table to serialize.
-- @tparam string name The name to use for this savegame.
--
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

---
-- Loads a savegame from the specified path.
-- @tparam  string path The path to load the savegame from.
-- @treturn table       The loaded and deserialized game data.
--
function SaveHandler.load( path )
    return Compressor.load( path .. '/' .. COMPRESSED_SAVE )
end

---
-- Loads a version file from the specified path.
-- @tparam  string path The path to load the version from.
-- @treturn string      The loaded version.
--
function SaveHandler.loadVersion( path )
    local result, error = Compressor.load( path .. '/' .. VERSION_FILE )
    if not result then
        Log.warn( error, 'SaveHandler' )
        return '<undefined>'
    end
    return result.version
end

---
-- Validates the savegame.
-- @tparam string path The save path to check.
--
function SaveHandler.validateSave( path )
    if not love.filesystem.getInfo( path .. '/' .. VERSION_FILE ) then
        Log.warn( string.format( VERSION_FILE_WARNING, path ), 'SaveHandler' )
        return false, '0.0.0.0'
    end

    local result, error = Compressor.load( path .. '/' .. VERSION_FILE )
    if not result then
        Log.warn( error, 'SaveHandler' )
        return false, '0.0.0.0'
    end

    if not love.filesystem.getInfo( path .. '/' .. COMPRESSED_SAVE ) then
        Log.warn( string.format( SAVE_FILE_WARNING, path ), 'SaveHandler' )
        return false, result.version
    end

    if getVersion() ~= result.version then
        Log.warn( string.format( VERSION_MISMATCH_WARNING, result.version, getVersion() ), 'SaveHandler' )
        return false, result.version
    end

    return true, result.version
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
-- @treturn table The player faction data.
--
function SaveHandler.pastePlayerFaction()
    return Compressor.load( TEMP_FOLDER .. '/' .. PLAYER_FACTION_SAVE )
end

---
-- Removes all files in the temporary folder and the folder itself from the
-- player's save directory.
--
function SaveHandler.removeTemporaryFiles()
    Log.info( 'Removing temporary files...', 'SaveHandler' )

    for _, item in pairs( love.filesystem.getDirectoryItems( TEMP_FOLDER )) do
        love.filesystem.remove( TEMP_FOLDER .. '/' .. item )
    end
    love.filesystem.remove( TEMP_FOLDER )
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the path to the save directory.
-- @treturn string The path to the save directory.
--
function SaveHandler.getSaveFolder()
    return SAVE_FOLDER
end

return SaveHandler
