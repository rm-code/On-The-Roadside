local Action = require('src.characters.actions.Action');
local Messenger = require( 'src.Messenger' );

local Close = {};

function Close.new( character, tile )
    local self = Action.new( 3, tile ):addInstance( 'Close' );

    function self:perform()
        local target = tile:getWorldObject();
        assert( target:isOpenable(), 'Target needs to be openable!' );
        assert( target:isPassable(), 'Target tile needs to be passable!' );
        assert( tile:isAdjacent( character:getTile() ), 'Character has to be adjacent to the target tile!' );

        Messenger.publish( 'ACTION_DOOR' );

        target:setPassable( false );
        target:setBlocksVision( true );

        tile:setDirty( true );
    end

    return self;
end

return Close;
