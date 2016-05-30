local Object = require( 'src.Object' );

local Item = {};

function Item.new( name )
    local self = Object.new():addInstance( 'Item' );

    function self:getName()
        return name;
    end

    return self;
end

return Item;
