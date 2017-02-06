local Log = {};

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

local function appendlineBreak()
    love.filesystem.append( 'latest.log', '\n' );
end

local function write( str, caller, mtype )
    local c, t = caller and string.format( '[%s]', caller ) or '', mtype or '';

    love.filesystem.append( 'latest.log', t );
    love.filesystem.append( 'latest.log', c );

    love.filesystem.append( 'latest.log', ' ' );
    if type( str ) ~= 'string' then
        love.filesystem.append( 'latest.log', 'Can\'t log ' ..  type( str ));
        return;
    end
    love.filesystem.append( 'latest.log', str );

    print( string.format( '%s%s %s', t, c, str ));
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function Log.init()
    love.filesystem.write( 'latest.log', '' );
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
