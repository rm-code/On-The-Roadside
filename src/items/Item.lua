local Object = require( 'src.Object' );

local Item = {};

function Item.new( template )
    local self = Object.new():addInstance( 'Item' );

    function self:getID()
        return template.id;
    end

    function self:getItemType()
        return template.itemType;
    end

    function self:serialize()
        local t = {
            ['id'] = template.id,
            ['itemType'] = template.itemType
        };
        return t;
    end

    return self;
end

return Item;
