local Messenger = require( 'src.Messenger' );

local SoundManager = {};

local SOUNDS = {
    DOOR   = love.audio.newSource( 'res/sounds/door.wav' );
    SELECT = love.audio.newSource( 'res/sounds/select.wav' );
    SHOOT  = love.audio.newSource( 'res/sounds/shoot.wav' );
}

Messenger.observe( 'ACTION_DOOR', function()
    love.audio.play( SOUNDS.DOOR );
end)

Messenger.observe( 'ACTION_SHOOT', function()
    love.audio.play( SOUNDS.SHOOT );
end)

Messenger.observe( 'SWITCH_CHARACTERS', function()
    love.audio.play( SOUNDS.SELECT );
end)

return SoundManager;
