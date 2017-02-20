local Object = require( 'src.Object' );

local EquipmentSlot = {};

function EquipmentSlot.new( index, template )
    local self = Object.new():addInstance( 'EquipmentSlot' );

    local item;

    function self:getIndex()
        return index;
    end

    function self:getID()
        return template.id;
    end

    function self:addItem( nitem )
        assert( nitem:getItemType() == self:getItemType(), "Item types do not match." );
        item = nitem;
        return true;
    end

    function self:getItem()
        return item;
    end

    function self:removeItem()
        assert( item ~= nil, "Can't remove item from an empty slot." );
        item = nil;
    end

    function self:getAndRemoveItem()
        local tmp = item;
        item = nil;
        return tmp;
    end

    function self:getItemType()
        return template.itemType;
    end

    function self:getSubType()
        return template.subType;
    end

    function self:containsItem()
        return item ~= nil;
    end

    function self:getSortOrder()
        return template.sort;
    end

    return self;
end

return EquipmentSlot;
