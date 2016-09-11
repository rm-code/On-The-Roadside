local Clothing = require( 'src.items.clothes.Clothing' );

local Shirt = {};

function Shirt.new( name, type, armor )
    return Clothing.new( name, type, armor ):addInstance( 'Shirt' );
end

return Shirt;
