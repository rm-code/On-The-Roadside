local Item = require( 'src.items.Item' );

local Clothing = {};

function Clothing.new( name, type, clothingType )
    local self = Item.new( name, type ):addInstance( 'Clothing' );

    function self:getClothingType()
        return clothingType;
    end

    return self;
end

return Clothing;
