local Log = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MAX_FILE_SIZE = 500000;
local FILE_NAME = 'latest.log';

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

local function appendlineBreak()
    love.filesystem.append( FILE_NAME, '\n' );
end

local function write( str, caller, mtype )
    if love.filesystem.getSize( FILE_NAME ) > MAX_FILE_SIZE then
        love.filesystem.write( FILE_NAME, '' );
    end

    local c, t = caller and string.format( '[%s]', caller ) or '', mtype or '';

    love.filesystem.append( FILE_NAME, t );
    love.filesystem.append( FILE_NAME, c );

    love.filesystem.append( FILE_NAME, ' ' );
    if type( str ) ~= 'string' then
        love.filesystem.append( FILE_NAME, 'Can\'t log ' ..  type( str ));
        return;
    end
    love.filesystem.append( FILE_NAME, str );

    print( string.format( '%s%s %s', t, c, str ));
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function Log.init()
    love.filesystem.write( FILE_NAME, '' );
end

function Log.print( str, caller )
    write( str, caller, '' );
    appendlineBreak();
end

function Log.info( str, caller )
    write( str, caller, '[INFO]' );
    appendlineBreak();
end

function Log.warn( str, caller )
    write( str, caller, '[WARNING]' );
    appendlineBreak();
end

function Log.error( str, caller )
    write( str, caller, '[ERROR]' );
    appendlineBreak();
end

function Log.debug( str, caller )
    write( str, caller, '[DEBUG]' );
    appendlineBreak();
end

return Log;
