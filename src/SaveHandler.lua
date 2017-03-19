local Log = require( 'src.util.Log' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SaveHandler = {};

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

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function SaveHandler.save( t )
    local output = {};
    table.insert( output, 'return {' );
    serialize( t, output, 0 )
    table.insert( output, '}' );

    local str = table.concat( output, '\n' );
    -- love.filesystem.write( 'uncompressed.lua', str );

    local compress = love.math.compress( str, 'lz4', 9 );
    love.filesystem.write( 'compressed.data', compress );
end

function SaveHandler.load()
    local compressed, bytes = love.filesystem.read( 'compressed.data' );
    Log.print( string.format( 'Loaded savegame (Size: %d bytes)', bytes ), 'SaveHandler' );

    local decompressed = love.math.decompress( compressed, 'lz4' );
    local rawsave = loadstring( decompressed )();
    return convertStrings( rawsave );
end

function SaveHandler.exists()
    return love.filesystem.exists( 'compressed.data' );
end

return SaveHandler;
