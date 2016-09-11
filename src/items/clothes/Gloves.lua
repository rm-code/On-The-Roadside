local Clothing = require( 'src.items.clothes.Clothing' );

local Gloves = {};

function Gloves.new( name, type, armor )
    return Clothing.new( name, type, armor ):addInstance( 'Gloves' );
end

return Gloves;
