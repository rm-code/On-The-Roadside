local EquipmentSlot = require( 'src.inventory.EquipmentSlot' );

local ClothingSlot = {};

function ClothingSlot.new( itemType, clothingType )
    local self = EquipmentSlot.new( itemType ):addInstance( 'ClothingSlot' );

    function self:getClothingType()
        return clothingType;
    end

    return self;
end

return ClothingSlot;
