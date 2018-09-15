---
-- The Compressor module takes care of serializing, compressing and saving data
-- to the harddisk, as well as loading and deserializing / decompressing it again.
--
-- @module Compressor
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Serialize = require( 'lib.Ser' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Compressor = {}

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Serializes and compresses the provided data.
-- Throws an error if the file can't be written to disk.
-- @tparam table  t    The data table to serialize and compress.
-- @tparam string path The path to save the serialized data at.
--
function Compressor.save( t, path )
    local rawstring = Serialize( t )
    local compressedData = love.data.compress( 'data', 'lz4', rawstring )
    assert( love.filesystem.write( path, compressedData ))
end

---
-- Deserializes and decompresses a file and returns the data table.
-- Throws an error if the loading fails.
-- @tparam  string path The path to load the serialized data from.
-- @treturn table       The loaded data.
--
function Compressor.load( path )
    -- Load file and throw an error if something went wrong.
    local compressedData, errorMessage = love.filesystem.read( path )
    assert( compressedData, errorMessage )

    -- Decompress the loaded Lua file to a string.
    local rawstring = love.data.decompress( 'string', 'lz4', compressedData )

    -- Return the error code if something went wrong while loading the Lua code.
    local result, error = load( rawstring )
    if not result then
        return result, error
    end

    -- Load and execute the actual Lua code.
    return result()
end

return Compressor
