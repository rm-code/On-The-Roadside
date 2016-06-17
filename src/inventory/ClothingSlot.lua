local StorageSlot = require( 'src.inventory.StorageSlot' );

local ClothingSlot = {};

function ClothingSlot.new( itemType, clothingType )
    local self = StorageSlot.new( itemType ):addInstance( 'ClothingSlot' );

    function self:getClothingType()
        return clothingType;
    end

    return self;
end

return ClothingSlot;
