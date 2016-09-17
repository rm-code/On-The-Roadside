local Clothing = require( 'src.items.clothes.Clothing' );

local Shirt = {};

function Shirt.new( id, type, armor )
    return Clothing.new( id, type, armor ):addInstance( 'Shirt' );
end

return Shirt;
