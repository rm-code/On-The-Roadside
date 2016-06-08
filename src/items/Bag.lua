local Item = require( 'src.items.Item' );

local Bag = {};

function Bag.new( name, type, slots )
    local self = Item.new( name, type ):addInstance( 'Bag' );

    return self;
end

return Bag;
