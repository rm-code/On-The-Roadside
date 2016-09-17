local Clothing = require( 'src.items.clothes.Clothing' );

local Footwear = {};

function Footwear.new( id, type, armor )
    return Clothing.new( id, type, armor ):addInstance( 'Footwear' );
end

return Footwear;
