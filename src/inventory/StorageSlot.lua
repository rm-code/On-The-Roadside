local Object = require( 'src.Object' );

local StorageSlot = {};

function StorageSlot.new( itemType )
    local self = Object.new():addInstance( 'StorageSlot' );

    local item;

    function self:addItem( nitem )
        item = nitem;
    end

    function self:getItem()
        return item;
    end

    function self:removeItem()
        item = nil;
    end

    function self:isEmpty()
        return item == nil;
    end

    function self:getItemType()
        return itemType;
    end

    return self;
end

return StorageSlot;
