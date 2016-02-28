local Action = require('src.characters.actions.Action');
local Messenger = require( 'src.Messenger' );

local Attack = {};

function Attack.new( character, target )
    local self = Action.new( 5 ):addInstance( 'Attack' );

    function self:perform()
        local origin = character:getTile();

        Messenger.publish( 'ACTION_SHOOT', character, origin, target );

        character:removeLineOfSight();
    end

    return self;
end

return Attack;
