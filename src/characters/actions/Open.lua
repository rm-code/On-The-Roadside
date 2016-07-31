local Action = require('src.characters.actions.Action');
local Messenger = require( 'src.Messenger' );

local Open = {};

function Open.new( character, tile )
    local self = Action.new( tile:getWorldObject():getInteractionCost(), tile ):addInstance( 'Open' );

    function self:perform()
        local target = tile:getWorldObject();
        assert( target:isOpenable(), 'Target needs to be openable!' );
        assert( not target:isPassable(), 'Target tile needs to be impassable!' );
        assert( tile:isAdjacent( character:getTile() ), 'Character has to be adjacent to the target tile!' );

        Messenger.publish( 'ACTION_DOOR' );

        target:setPassable( true );
        target:setBlocksVision( false );

        tile:setDirty( true );
        return true;
    end

    return self;
end

return Open;
