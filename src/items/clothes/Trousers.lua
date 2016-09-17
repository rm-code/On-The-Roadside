local Clothing = require( 'src.items.clothes.Clothing' );

local Trousers = {};

function Trousers.new( id, type, armor )
    return Clothing.new( id, type, armor ):addInstance( 'Trousers' );
end

return Trousers;
