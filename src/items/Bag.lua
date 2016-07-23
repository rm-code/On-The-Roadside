local Item = require( 'src.items.Item' );
local Storage = require( 'src.inventory.Storage' );

local Bag = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ItemTypes');

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Bag.new( name, type, slots )
    local self = Item.new( name, type ):addInstance( 'Bag' );

    local storage = Storage.new( slots );

    function self:getStorage()
        return storage;
    end

    return self;
end

return Bag;
