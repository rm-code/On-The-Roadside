local Item = require( 'src.items.Item' );

local Clothing = {};

function Clothing.new( name, armor, type, clothingType )
    local self = Item.new( name, type ):addInstance( 'Clothing' );

    function self:getClothingType()
        return clothingType;
    end

    function self:getArmor()
        return armor;
    end

    return self;
end

return Clothing;
