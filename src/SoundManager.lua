---
-- @module SoundManager
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SoundManager = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SOUNDFILES_FOLDER = 'res/sounds/'
local INFO_FILE_NAME = 'info'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local sounds = {}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads sound files from the provided path.
-- @tparam string path The path to check for sounds.
--
local function load( path )
    local info = require( path .. INFO_FILE_NAME )
    if not info then
        return false
    end

    local count = 0
    for id, source in pairs( info.sounds ) do
        local filepath = SOUNDFILES_FOLDER .. source.file
        if love.filesystem.getInfo( filepath, 'file' ) then
            sounds[id] = love.audio.newSource( filepath, source.type )

            count = count + 1
            Log.print( string.format( '  %3d. %s', count, id ), 'SoundManager' )
        else
            Log.warn( string.format( 'Source file "%s" for id "%s" couldn\'t be found', source.file, id ), 'SoundManager' )
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function SoundManager.load()
    Log.print( "Loading Sounds:", 'SoundManager' )
    load( SOUNDFILES_FOLDER )
end

function SoundManager.play( id )
    if not sounds[id] then
        Log.warn( string.format( 'A sound with the id "%s" couldn\'t be found', id ), 'SoundManager' )
        return
    end

    sounds[id]:play()
end

return SoundManager
