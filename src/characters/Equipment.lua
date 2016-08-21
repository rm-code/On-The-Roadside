local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Equipment = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ItemTypes');

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new equipment instance.
-- @return (Equipment) The new equipment instance.
--
function Equipment.new()
    local self = Object.new():addInstance( 'Equipment' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local items = {};

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Adds a new item to its slot.
    -- @param item (Item) The item to add.
    --
    function self:addItem( item )
        local main = item:getItemType();
        items[main] = item;
    end

    ---
    -- Removes all items from their slots.
    --
    function self:clear()
        items[ITEM_TYPES.WEAPON]   = nil;
        items[ITEM_TYPES.BAG]      = nil;
        items[ITEM_TYPES.HEADGEAR] = nil;
        items[ITEM_TYPES.GLOVES]   = nil;
        items[ITEM_TYPES.JACKET]   = nil;
        items[ITEM_TYPES.SHIRT]    = nil;
        items[ITEM_TYPES.TROUSERS] = nil;
        items[ITEM_TYPES.FOOTWEAR] = nil;
    end

    ---
    -- Removes a item from its slot.
    -- @param item (Item) The item to remove.
    -- @return     (Item) The removed item.
    --
    function self:removeItem( item )
        local main = item:getItemType();
        local tmp = items[main];
        items[main] = nil;
        return tmp;
    end

    ---
    -- Checks if the item is in any of the slots.
    -- @param item (Item)    The item to check for.
    -- @return     (boolean) Wether this item is contained in a slot.
    --
    function self:containsItem( item )
        local main = item:getItemType();
        return items[main] ~= nil;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the item in the backpack slot.
    -- @return (Bag) The bag item in the slot (or nil).
    --
    function self:getBackpack()
        return items[ITEM_TYPES.BAG];
    end

    ---
    -- Returns the item in the specific clothing slot.
    -- @return (Clothing) The clothing item in the slot (or nil).
    --
    function self:getClothingItem( part )
        return items[part];
    end

    ---
    -- Returns all items.
    -- @return (table) All items in the inventory.
    --
    function self:getItems()
        return items;
    end

    ---
    -- Returns the item in the weapon slot.
    -- @return (Weapon) The weapon item in the slot (or nil).
    --
    function self:getWeapon()
        return items[ITEM_TYPES.WEAPON];
    end

    return self;
end

return Equipment;
