---
-- This module offers functions to save and load temporary game data. The data
-- is stored on the harddisk and loaded again if needed. This can be used to
-- pass around the data between different states.
--
-- @module DataHandler
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Compressor = require( 'src.util.Compressor' )
-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local DataHandler = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEMP_FOLDER = 'tmp'
local PLAYER_FACTION_SAVE = 'tmp_faction.data'
local BASE_INVENTORY_SAVE = 'tmp_base_inventory.data'

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Copies data to the harddrive.
-- @tparam table data The data to save.
-- @tparam string file The target file.
--
local function copyData( data, file )
    -- Create the target folder it doesn't exist already.
    if not love.filesystem.getInfo( TEMP_FOLDER ) then
        love.filesystem.createDirectory( TEMP_FOLDER )
    end

    Compressor.save( data, string.format( '%s/%s', TEMP_FOLDER, file ))
end

---
-- Loads data from a file on the harddrive.
-- @tparam string file The target file to load.
-- @treturn table The loaded data.
--
local function loadData( file )
    return Compressor.load( string.format( '%s/%s', TEMP_FOLDER, file ))
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Copies the current player faction to the harddisk as a temporary file.
-- This should only be used to copy and paste the player faction data between
-- different states.
-- @tparam table t The player faction data.
--
function DataHandler.copyPlayerFaction( t )
    Log.info( 'Saving player faction...', 'DataHandler' )
    copyData( t, PLAYER_FACTION_SAVE )
end

---
-- Copies the base inventory to the harddisk as a temporary file.
-- This should only be used to copy and paste the base inventory data between
-- different states.
-- @tparam table t The base inventory data.
--
function DataHandler.copyBaseInventory( t )
    Log.info( 'Saving base inventory...', 'DataHandler' )
    copyData( t, BASE_INVENTORY_SAVE )
end

---
-- Loads the temporary player faction file from the harddisk.
-- This should only be used to copy and paste the player faction data between
-- different states.
-- @treturn table The player faction data.
--
function DataHandler.pastePlayerFaction()
    Log.info( 'Loading player faction...', 'DataHandler' )
    return loadData( PLAYER_FACTION_SAVE )
end

---
-- Loads the base inventory file from the harddisk.
-- This should only be used to copy and paste the base inventory data between
-- different states.
-- @treturn table The base inventory data.
--
function DataHandler.pasteBaseInventory()
    Log.info( 'Loading base inventory...', 'DataHandler' )
    return loadData( BASE_INVENTORY_SAVE )
end

---
-- Removes all files in the temporary folder and the folder itself from the
-- player's save directory.
--
function DataHandler.removeTemporaryFiles()
    Log.info( 'Removing temporary files...', 'DataHandler' )

    for _, item in pairs( love.filesystem.getDirectoryItems( TEMP_FOLDER )) do
        love.filesystem.remove( TEMP_FOLDER .. '/' .. item )
    end
    love.filesystem.remove( TEMP_FOLDER )
end

return DataHandler
