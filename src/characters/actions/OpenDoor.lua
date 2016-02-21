local Object = require('src.Object');

local OpenDoor = {};

function OpenDoor.new( character, target )
    local self = Object.new():addInstance( 'OpenDoor' );

    function self:perform()
        if target:instanceOf( 'Door' ) and not target:isPassable() and target:isAdjacent( character:getTile() ) then
            target:setOpen( true );
            target:setDirty( true );
        end
    end

    function self:getCost()
        return 3;
    end

    return self;
end

return OpenDoor;
