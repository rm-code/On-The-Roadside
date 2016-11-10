local Clothing = require( 'src.items.clothes.Clothing' );

local Gloves = {};

function Gloves.new( id, type, armor )
    return Clothing.new( id, type, armor ):addInstance( 'Gloves' );
end

return Gloves;
