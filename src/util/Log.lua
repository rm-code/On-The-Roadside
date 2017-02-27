local Log = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FILE_NAME = 'latest.log';

local DEBUG_PREFIX   = '[DEBUG]';
local WARNING_PREFIX = '[WARNING]';
local ERROR_PREFIX   = '[ERROR]';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local file;
local active = false;

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
    str = tostring( str );

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

function Log.warn( str, caller )
    write( str, caller, WARNING_PREFIX );
    appendlineBreak();
end

function Log.error( str, caller )
    write( str, caller, ERROR_PREFIX );
    appendlineBreak();
end

function Log.debug( str, caller )
    if not active then
        return;
    end
    write( str, caller, DEBUG_PREFIX );
    appendlineBreak();
end

function Log.setDebugActive( nactive )
    active = nactive;
end

function Log.getDebugActive()
    return active;
end

return Log;
