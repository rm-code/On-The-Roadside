local Clothing = require( 'src.items.clothes.Clothing' );

local Headgear = {};

function Headgear.new( id, type, armor )
    return Clothing.new( id, type, armor ):addInstance( 'Headgear' );
end

return Headgear;
