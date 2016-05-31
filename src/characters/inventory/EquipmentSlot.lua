local Object = require( 'src.Object' );

local EquipmentSlot = {};

function EquipmentSlot.new( itemType )
    local self = Object.new():addInstance( 'EquipmentSlot' );

    local item;

    function self:setItem( nitem )
        item = nitem;
    end

    function self:getItem()
        return item;
    end

    function self:getItemType()
        return itemType;
    end

    return self;
end

return EquipmentSlot;
