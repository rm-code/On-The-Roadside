local Action = require('src.characters.actions.Action');
local Messenger = require( 'src.Messenger' );

local OpenDoor = {};

function OpenDoor.new( character, tile )
    local self = Action.new( 3 ):addInstance( 'OpenDoor' );

    function self:perform()
        local target = tile:getWorldObject();
        assert( target:getType() == 'worldobject_door', 'Target tile needs to be of type Door!' );
        assert( not target:isPassable(), 'Target tile needs to be impassable!' );
        assert( tile:isAdjacent( character:getTile() ), 'Character has to be adjacent to the target tile!' );

        Messenger.publish( 'ACTION_DOOR' );

        target:setPassable( true );
        target:setBlocksVision( false );
        tile:setDirty( true );
    end

    return self;
end

return OpenDoor;
