local Object = require('src.Object');

local OpenDoor = {};

function OpenDoor.new( character, target )
    local self = Object.new():addInstance( 'OpenDoor' );

    function self:perform()
        assert( target:instanceOf( 'Door' ), 'Target tile needs to be an instance of Door!' );
        assert( not target:isPassable(), 'Target tile needs to be impassable!' );
        assert( target:isAdjacent( character:getTile() ), 'Character has to be adjacent to the target tile!' );

        target:setPassable( true );
        target:setDirty( true );
    end

    function self:getCost()
        return 3;
    end

    return self;
end

return OpenDoor;
