local Action = require('src.characters.actions.Action');
local Messenger = require( 'src.Messenger' );

local CloseDoor = {};

function CloseDoor.new( character, tile )
    local self = Action.new( 3 ):addInstance( 'CloseDoor' );

    function self:perform()
        local target = tile:getWorldObject();
        assert( target:instanceOf( 'Door' ), 'Target tile needs to be an instance of Door!' );
        assert( target:isPassable(), 'Target tile needs to be passable!' );
        assert( tile:isAdjacent( character:getTile() ), 'Character has to be adjacent to the target tile!' );

        Messenger.publish( 'ACTION_DOOR' );

        target:setPassable( false );
        tile:setDirty( true );
    end

    return self;
end

return CloseDoor;
