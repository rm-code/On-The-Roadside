local Item = require( 'src.items.Item' );
local Inventory = require( 'src.inventory.Inventory' );

local Bag = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Bag.new( template )
    local self = Item.new( template.name, template.itemType ):addInstance( 'Bag' );

    local inventory = Inventory.new();

    function self:getInventory()
        return inventory;
    end

    function self:serialize()
        local t = {
            ['name'] = template.name,
            ['itemType'] = template.itemType,
            ['inventory'] = inventory:serialize()
        };
        return t;
    end

    return self;
end

return Bag;
