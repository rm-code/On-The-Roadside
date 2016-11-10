local Messenger = require( 'src.Messenger' );

local SoundManager = {};

local SOUNDS = {}

---
-- Stops a source if it is currently playing.
-- @param source (Source) The source to stop.
-- @return       (Source) The stopped source.
--
local function stopBeforePlaying( source )
    if source:isPlaying() then
        source:stop();
    end
    return source;
end

function SoundManager.loadResources()
    SOUNDS.DOOR           = love.audio.newSource( 'res/sounds/door.wav' );
    SOUNDS.SELECT         = love.audio.newSource( 'res/sounds/select.wav' );
    SOUNDS.ASSAULT_RIFLE  = love.audio.newSource( 'res/sounds/ar.wav' );
    SOUNDS.SHOTGUN        = love.audio.newSource( 'res/sounds/ar.wav' );
    SOUNDS.CLIMB          = love.audio.newSource( 'res/sounds/climb.wav' );
    SOUNDS.EXPLODE        = love.audio.newSource( 'res/sounds/explosion.wav' );
    SOUNDS.ROCKET_LAUNCHER = love.audio.newSource( 'res/sounds/rocket.wav' );
    SOUNDS.MELEE          = love.audio.newSource( 'res/sounds/melee.wav' );
end

Messenger.observe( 'ACTION_DOOR', function()
    love.audio.play( SOUNDS.DOOR );
end)

Messenger.observe( 'SOUND_CLIMB', function()
    love.audio.play( SOUNDS.CLIMB );
end)

Messenger.observe( 'SOUND_ATTACK', function( weapon )
    if not SOUNDS[weapon:getSound()] then
        print( string.format( 'ERROR: Sound file for %s doesn\'t exist', weapon:getID() ));
        return;
    end
    love.audio.play( stopBeforePlaying( SOUNDS[weapon:getSound()] ));
end)

Messenger.observe( 'SWITCH_CHARACTERS', function()
    love.audio.play( SOUNDS.SELECT );
end)

Messenger.observe( 'EXPLOSION', function()
    love.audio.play( SOUNDS.EXPLODE );
end)

return SoundManager;
