local Clothing = require( 'src.items.clothes.Clothing' );

local Jacket = {};

function Jacket.new( id, type, armor )
    return Clothing.new( id, type, armor ):addInstance( 'Jacket' );
end

return Jacket;
