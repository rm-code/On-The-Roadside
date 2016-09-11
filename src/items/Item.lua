local Object = require( 'src.Object' );

local Item = {};

function Item.new( name, itemType )
    local self = Object.new():addInstance( 'Item' );

    function self:getName()
        return name;
    end

    function self:getItemType()
        return itemType;
    end

    function self:serialize()
        local t = {
            ['name'] = name,
            ['itemType'] = itemType
        };
        return t;
    end

    return self;
end

return Item;
