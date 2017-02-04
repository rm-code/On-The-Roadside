local Action = require( 'src.characters.actions.Action' );
local Messenger = require( 'src.Messenger' );

local ClimbOver = {};

function ClimbOver.new( character, target )
    local self = Action.new( target:getWorldObject():getInteractionCost(), target ):addInstance( 'ClimbOver' );

    function self:perform()
        local current = character:getTile();

        assert( target:isAdjacent( current ), 'Character has to be adjacent to the target tile!' );

        current:removeCharacter();
        target:addCharacter( character );
        character:setTile( target );

        Messenger.publish( 'SOUND_CLIMB' );
        return true;
    end

    return self;
end

return ClimbOver;
