local Object = require('src.Object');

local CloseDoor = {};

function CloseDoor.new( character, target )
    local self = Object.new():addInstance( 'CloseDoor' );

    function self:perform()
        local obj = target:getWorldObject();
        if obj:instanceOf( 'Door' ) and obj:isOpen() and target:isAdjacent( character:getTile() ) then
            obj:setOpen( false );
            target:setDirty( true );
        end
    end

    function self:getCost()
        return 3;
    end

    return self;
end

return CloseDoor;
