---
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
-- Constructor
-- ------------------------------------------------

function Compressor.save( t, path )
    local rawstring = Serialize( t )
    local compressedData = love.data.compress( 'data', 'lz4', rawstring )
    assert( love.filesystem.write( path, compressedData ))
end

function Compressor.load( path )
    -- Load file and throw an error if something went wrong.
    local compressedData, errorMessage = love.filesystem.read( path )
    assert( compressedData, errorMessage )

    -- Decompress and return the loaded lua file.
    local rawstring = love.data.decompress( 'string', 'lz4', compressedData )

    -- Print a warning if it can't be loaded and return false.
    local result, error = load( rawstring )
    if not result then
        return result, error
    end

    return load( rawstring )()
end

return Compressor
