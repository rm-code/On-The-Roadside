local Object = require( 'src.Object' );

local Item = {};

function Item.new( name, itemType, subType )
    local self = Object.new():addInstance( 'Item' );

    function self:getName()
        return name;
    end

    function self:getItemType()
        return itemType;
    end

    function self:getSubType()
        return subType;
    end

    return self;
end

return Item;
