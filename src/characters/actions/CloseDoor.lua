local Object = require('src.Object');

local CloseDoor = {};

function CloseDoor.new( character, target )
    local self = Object.new():addInstance( 'CloseDoor' );

    function self:perform()
        assert( target:instanceOf( 'Door' ), 'Target tile needs to be an instance of Door!' );
        assert( target:isPassable(), 'Target tile needs to be passable!' );
        assert( target:isAdjacent( character:getTile() ), 'Character has to be adjacent to the target tile!' );

        target:setPassable( false );
        target:setDirty( true );
    end

    function self:getCost()
        return 3;
    end

    return self;
end

return CloseDoor;
