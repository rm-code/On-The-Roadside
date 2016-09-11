local Clothing = require( 'src.items.clothes.Clothing' );

local Headgear = {};

function Headgear.new( name, type, armor )
    return Clothing.new( name, type, armor ):addInstance( 'Headgear' );
end

return Headgear;
