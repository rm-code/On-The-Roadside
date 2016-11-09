local Item = require( 'src.items.Item' );
local Inventory = require( 'src.inventory.Inventory' );

local Bag = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Bag.new( template )
    local self = Item.new( template ):addInstance( 'Bag' );

    local inventory = Inventory.new( template.weightLimit, template.volumeLimit );

    function self:getInventory()
        return inventory;
    end

    function self:serialize()
        local t = {
            ['id'] = template.id,
            ['itemType'] = template.itemType,
            ['inventory'] = inventory:serialize()
        };
        return t;
    end

    return self;
end

return Bag;
