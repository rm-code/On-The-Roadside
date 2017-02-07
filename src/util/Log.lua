local Log = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FILE_NAME = 'latest.log';
local MAX_SIZE = 1000000;

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local file;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

local function recreateFile()
    file = love.filesystem.remove( FILE_NAME );
    file = love.filesystem.newFile( FILE_NAME, 'a' );
end

local function appendlineBreak()
    file:write( '\n' );
end

local function write( str, caller, mtype )
    if love.filesystem.getSize( FILE_NAME ) > MAX_SIZE then
        recreateFile();
    end

    local c, t = caller and string.format( '[%s]', caller ) or '', mtype or '';
    file:write( t );
    file:write( c );

    file:write( ' ' );
    if type( str ) ~= 'string' then
        file:write( 'Can\'t log ' ..  type( str ));
        return;
    end
    file:write( str );

    print( string.format( '%s%s %s', t, c, str ));
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function Log.init()
    recreateFile();
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
