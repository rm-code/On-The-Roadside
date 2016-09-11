local Clothing = require( 'src.items.clothes.Clothing' );

local Footwear = {};

function Footwear.new( name, type, armor )
    return Clothing.new( name, type, armor ):addInstance( 'Footwear' );
end

return Footwear;
