local Object = require( 'src.Object' );

local Item = {};

function Item.new( id, itemType )
    local self = Object.new():addInstance( 'Item' );

    function self:getID()
        return id;
    end

    function self:getItemType()
        return itemType;
    end

    function self:serialize()
        local t = {
            ['id'] = id,
            ['itemType'] = itemType
        };
        return t;
    end

    return self;
end

return Item;
