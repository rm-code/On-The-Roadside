local Item = require( 'src.items.Item' );

local Bag = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Bag.new( template )
    local self = Item.new( template ):addInstance( 'Bag' );

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

return Bag;
