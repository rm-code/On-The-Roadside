---
-- This module handles the saving and loading of savegames.
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
local TYPE_FILE = 'type.data'

local VERSION_FILE_WARNING = 'Can not load a version file from "%s"'
local SAVE_FILE_WARNING = 'Can not load a save file from "%s"'
local VERSION_MISMATCH_WARNING = 'Save file "%s" (%s) doesn\'t match the current game version (%s).'

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Creates a file in the target folder.
-- @tparam table  data The data table to write to the file.
-- @tparam string dir     The directory to store the file in.
-- @tparam string file    The file to store the data in.
--
local function createFile( data, dir, file )
    Compressor.save( data, dir .. '/' .. file )
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

    createFile( { version = getVersion() }, folder, VERSION_FILE )
    createFile( { type = t.type }, folder, TYPE_FILE )
    createFile( t, folder, COMPRESSED_SAVE )
end

---
-- Loads a savegame from a specific folder.
-- @tparam  string folder The folder to load the savegame from.
-- @treturn table         The loaded and deserialized game data.
--
function SaveHandler.load( folder )
    return Compressor.load( string.format( '%s/%s/%s', SAVE_FOLDER, folder, COMPRESSED_SAVE ))
end

---
-- Loads the type file of a specific savegame.
-- @tparam  string folder The folder to load the file from.
-- @treturn table         The loaded and deserialized type file.
--
function SaveHandler.loadSaveType( folder )
    if not love.filesystem.getInfo( string.format( '%s/%s/%s', SAVE_FOLDER, folder, TYPE_FILE )) then
        return { type = 'error' }
    end
    return Compressor.load( string.format( '%s/%s/%s', SAVE_FOLDER, folder, TYPE_FILE ))
end

---
-- Validates the savegame.
-- @tparam string folder The folder to check.
--
function SaveHandler.validateSave( folder )
    if not love.filesystem.getInfo( string.format( '%s/%s/%s', SAVE_FOLDER, folder, VERSION_FILE )) then
        Log.warn( string.format( VERSION_FILE_WARNING, folder ), 'SaveHandler' )
        return false, '0.0.0.0'
    end

    local result, error = Compressor.load( string.format( '%s/%s/%s', SAVE_FOLDER, folder, VERSION_FILE ))
    if not result then
        Log.warn( error, 'SaveHandler' )
        return false, '0.0.0.0'
    end

    if not love.filesystem.getInfo( string.format( '%s/%s/%s', SAVE_FOLDER, folder, COMPRESSED_SAVE )) then
        Log.warn( string.format( SAVE_FILE_WARNING, folder ), 'SaveHandler' )
        return false, result.version
    end

    if getVersion() ~= result.version then
        Log.warn( string.format( VERSION_MISMATCH_WARNING, folder, result.version, getVersion() ), 'SaveHandler' )
        return false, result.version
    end

    return true, result.version
end

---
-- Deletes a savegame folder.
-- @tparam  string folder The folder to delete.
--
function SaveHandler.deleteSave( folder )
    Log.info( string.format( 'Removing save file "%s".', folder ), 'SaveHandler' )

    local path = string.format( '%s/%s', SAVE_FOLDER, folder )

    for _, item in pairs( love.filesystem.getDirectoryItems( path )) do
        love.filesystem.remove( path .. '/' .. item )
    end
    love.filesystem.remove( path )
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
