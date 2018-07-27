---
-- The log module handles logging of any system events to both the console and
-- a log file on the hard disk.
--
-- If the debugging flag is set to active it will also log DEBUG events.
--
-- @module Log
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FILE_NAME = 'latest.log'

local CRASH_FOLDER = 'crash_dumps/'
local CRASH_FILE_NAME = '%s%s_crash.log'

local INFO_PREFIX    = '[INFO]'
local DEBUG_PREFIX   = '[DEBUG]'
local WARNING_PREFIX = '[WARNING]'
local ERROR_PREFIX   = '[ERROR]'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local file
local active = false -- DEBUG flag

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Recreates the log file in the filesystem.
--
local function recreateFile()
    file = love.filesystem.remove( FILE_NAME )
    file = love.filesystem.newFile( FILE_NAME, 'a' )
end

---
-- Appends a linebreak to the log file.
--
local function appendlineBreak()
    file:write( '\n' )
end

---
-- Writes a message to log file and the console.
--
-- Logged messages follow a common layout:
--      [MESSAGE_TYPE][CALLER] Message text.
--
-- @tparam string str    The message to log.
-- @tparam string caller The module which sent the message.
-- @tparam string mtype  The type of the message to log.
--
local function write( str, caller, mtype )
    str = tostring( str )

    local c, t = caller and string.format( '[%s]', caller ) or '', mtype or ''
    file:write( t )
    file:write( c )

    file:write( ' ' )
    if type( str ) ~= 'string' then
        file:write( 'Can\'t log ' ..  type( str ))
        return
    end
    file:write( str )

    print( string.format( '%s%s %s', t, c, str ))
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Initialises the Log module.
--
function Log.init()
    recreateFile()
end

---
-- Logs a message without prepending any special message type.
-- @tparam string str    The message to log.
-- @tparam string caller The module which sent the message.
--
function Log.print( str, caller )
    write( str, caller, '' )
    appendlineBreak()
end

---
-- Logs a informational message.
-- @tparam string str    The message to log.
-- @tparam string caller The module which sent the message.
--
function Log.info( str, caller )
    write( str, caller, INFO_PREFIX )
    appendlineBreak()
end

---
-- Logs a warning message.
-- @tparam string str    The message to log.
-- @tparam string caller The module which sent the message.
--
function Log.warn( str, caller )
    write( str, caller, WARNING_PREFIX )
    appendlineBreak()
end

---
-- Logs an error message.
-- @tparam string str    The message to log.
-- @tparam string caller The module which sent the message.
--
function Log.error( str, caller )
    write( str, caller, ERROR_PREFIX )
    appendlineBreak()
end

---
-- Logs a debug message.
-- @tparam string str    The message to log.
-- @tparam string caller The module which sent the message.
--
function Log.debug( str, caller )
    if not active then
        return
    end
    write( str, caller, DEBUG_PREFIX )
    appendlineBreak()
end

---
-- Activates or deactivates the debug logging.
-- @tparam boolean nactive The new state.
--
function Log.setDebugActive( nactive )
    active = nactive
end

---
-- Returns wether debug logging is active or not.
-- @treturn boolean The current state.
--
function Log.getDebugActive()
    return active
end

---
-- Saves a copy of the latest.log to the crash dump folder and timestamps it.
--
function Log.saveCrashDump()
    love.filesystem.createDirectory( CRASH_FOLDER )
    assert( love.filesystem.write( string.format( CRASH_FILE_NAME, CRASH_FOLDER, os.time() ), love.filesystem.read( FILE_NAME )))
end

return Log
