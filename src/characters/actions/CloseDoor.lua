local Action = require('src.characters.actions.Action');
local Messenger = require( 'src.Messenger' );

local CloseDoor = {};

function CloseDoor.new( character, target )
    local self = Action.new( 3 ):addInstance( 'CloseDoor' );

    function self:perform()
        assert( target:instanceOf( 'Door' ), 'Target tile needs to be an instance of Door!' );
        assert( target:isPassable(), 'Target tile needs to be passable!' );
        assert( target:isAdjacent( character:getTile() ), 'Character has to be adjacent to the target tile!' );

        Messenger.publish( 'ACTION_DOOR' );

        target:setPassable( false );
        target:setDirty( true );
    end

    return self;
end

return CloseDoor;
