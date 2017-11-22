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
    local compressedData = love.math.compress( rawstring )
    assert( love.filesystem.write( path, compressedData ))
end

function Compressor.load( path )
    -- Load file and throw an error if something went wrong.
    local compressedData, errorMessage = love.filesystem.read( path )
    assert( compressedData, errorMessage )

    -- Decompress and return the loaded lua file.
    local rawstring = love.math.decompress( compressedData, 'lz4' )
    return load( rawstring )()
end

return Compressor
