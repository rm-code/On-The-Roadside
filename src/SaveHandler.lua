local Log = require( 'src.util.Log' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SaveHandler = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SAVE_FOLDER = 'saves'
local UNCOMPRESSED_SAVE = 'uncompressed.lua'
local COMPRESSED_SAVE = 'compressed.data'
local VERSION_FILE = 'version.data'
local DEBUG = false

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Takes a table and recursively turns it into a human-readable and nicely
-- formatted string stored as a sequence.
-- @param value  (mixed)  The value to serialize.
-- @param output (table)  The table used for storing the lines of the final file.
-- @param depth  (number) An indicator for the depth of the recursion.
--
local function serialize( value, output, depth )
    -- Append whitespace for each depth layer.
    local ws = '    ';
    for _ = 1, depth do
        ws = ws .. '    ';
    end

    if type( value ) == 'table' then
        for k, v in pairs(value) do
            if type( v ) == 'table' then
                table.insert( output, string.format( '%s[\'%s\'] = {', ws, tostring( k )));
                serialize( v, output, depth + 1 );
                table.insert( output, string.format( '%s},', ws ));
            elseif type( v ) == 'string' then
                table.insert( output, string.format( '%s[\'%s\'] = "%s",', ws, tostring( k ), tostring( v )));
            else
                table.insert( output, string.format( '%s[\'%s\'] = %s,', ws, tostring( k ), tostring( v )));
            end
        end
    else
        table.insert( output, string.format( '%s%s,', tostring( value )));
    end
end

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

local function createVersionFile( dir, version )
    love.filesystem.write( dir .. '/' .. VERSION_FILE, love.math.compress( version, 'lz4', 9 ))
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

    createVersionFile( folder, getVersion() )

    -- Serialize the table.
    local output = {};
    table.insert( output, 'return {' );
    serialize( t, output, 0 )
    table.insert( output, '}' );

    local str = table.concat( output, '\n' );
    local compress = love.math.compress( str, 'lz4', 9 );

    -- Save uncompressed output for debug purposes only.
    if DEBUG then
        love.filesystem.write( folder .. '/' .. UNCOMPRESSED_SAVE, str )
    end

    -- Save compressed file.
    love.filesystem.write( folder .. '/' .. COMPRESSED_SAVE, compress )
end

function SaveHandler.load( path )
    local compressed, bytes = love.filesystem.read( path .. '/' .. COMPRESSED_SAVE )
    Log.print( string.format( 'Loaded savegame (Size: %d bytes)', bytes ), 'SaveHandler' );

    local decompressed = love.math.decompress( compressed, 'lz4' );
    local rawsave = loadstring( decompressed )();
    return convertStrings( rawsave );
end

function SaveHandler.loadVersion( path )
    local compressed = love.filesystem.read( path .. '/' .. VERSION_FILE )
    return love.math.decompress( compressed, 'lz4' )
end

function SaveHandler.getSaveFolder()
    return SAVE_FOLDER
end

return SaveHandler;
