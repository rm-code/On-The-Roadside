local Object = require('src.Object');

local OpenDoor = {};

function OpenDoor.new( character, target )
    local self = Object.new():addInstance( 'OpenDoor' );

    function self:perform()
        local obj = target:getWorldObject();
        if obj:instanceOf( 'Door' ) and not obj:isOpen() and target:isAdjacent( character:getTile() ) then
            obj:setOpen( true );
            target:setDirty( true );
        end
    end

    function self:getCost()
        return 3;
    end

    return self;
end

return OpenDoor;
