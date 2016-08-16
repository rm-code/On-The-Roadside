local Clothing = require( 'src.items.clothes.Clothing' );

local Jacket = {};

function Jacket.new( name, type, armor )
    return Clothing.new( name, type, armor ):addInstance( 'Jacket' );
end

return Jacket;
