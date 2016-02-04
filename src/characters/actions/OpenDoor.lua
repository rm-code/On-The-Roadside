local Object = require('src.Object');

local OpenDoor = {};

function OpenDoor.new( character, target )
    local self = Object.new():addInstance( 'OpenDoor' );

    function self:perform()
        local obj = target:getWorldObject();
        if obj:instanceOf( 'Door' ) and not obj:isPassable() and target:isAdjacent( character:getTile() ) then
            obj:open();
            target:setDirty( true );
        end
    end

    return self;
end

return OpenDoor;
