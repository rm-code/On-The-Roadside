local Item = require( 'src.items.Item' );

local Container = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Container.new( template )
    local self = Item.new( template ):addInstance( 'Container' );

    function self:getCarryCapacity()
        return template.carryCapacity;
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

return Container;
