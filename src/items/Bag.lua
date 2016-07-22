local Item = require( 'src.items.Item' );
local Inventory = require( 'src.inventory.Inventory' );

local Bag = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Bag.new( name, type )
    local self = Item.new( name, type ):addInstance( 'Bag' );

    local inventory = Inventory.new();

    function self:getInventory()
        return inventory;
    end

    return self;
end

return Bag;
