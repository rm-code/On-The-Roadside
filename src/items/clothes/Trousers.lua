local Clothing = require( 'src.items.clothes.Clothing' );

local Trousers = {};

function Trousers.new( name, type, armor )
    return Clothing.new( name, type, armor ):addInstance( 'Trousers' );
end

return Trousers;
