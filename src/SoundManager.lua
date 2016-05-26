local Messenger = require( 'src.Messenger' );

local SoundManager = {};

local SOUNDS = {
    DOOR   = love.audio.newSource( 'res/sounds/door.wav' );
    SELECT = love.audio.newSource( 'res/sounds/select.wav' );
    SHOOT  = love.audio.newSource( 'res/sounds/shoot.wav' );
}

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

Messenger.observe( 'ACTION_DOOR', function()
    love.audio.play( SOUNDS.DOOR );
end)

Messenger.observe( 'SOUND_SHOOT', function()
    love.audio.play( stopBeforePlaying( SOUNDS.SHOOT ));
end)

Messenger.observe( 'SWITCH_CHARACTERS', function()
    love.audio.play( SOUNDS.SELECT );
end)

return SoundManager;
