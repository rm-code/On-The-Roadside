local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Inventory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ItemTypes');

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Inventory.new()
    local self = Object.new():addInstance( 'Inventory' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local items = {};

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Adds an item to the inventory.
    -- @param item (Item)    The item to add.
    -- @return     (boolean) True if the item was added successfully.
    --
    function self:addItem( item )
        items[#items + 1] = item;
        return true;
    end

    ---
    -- Removes an item from the inventory.
    -- @param item (Item)    The item to remove.
    -- @return     (boolean) True if the item was removed successfully.
    --
    function self:removeItem( item )
        for i = 1, #items do
            if items[i] == item then
                table.remove( items, i );
                return true;
            end
        end
        return false;
    end

    ---
    -- Serializes the inventory.
    -- @return (table) The serialized object.
    --
    function self:serialize()
        local t = {};
        for i = 1, #items do
            table.insert( t, items[i]:serialize() );
        end
        return t;
    end

    ---
    -- Checks if the inventory contains a certain type of item.
    -- @param type (string)  The type to check for.
    -- @return     (boolean) True if an item of the specified type was found.
    --
    function self:containsItemType( type )
        for i = 1, #items do
            if items[i]:getItemType() == type then
                return true;
            end
        end
        return false;
    end

    function self:getAndRemoveItem( type )
        for _, item in ipairs( items ) do
            if item:getItemType() == type then
                self:removeItem( item );
                return item;
            end
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getBackpack()
        return self:getItem( ITEM_TYPES.BAG );
    end

    function self:getWeapon()
        return self:getItem( ITEM_TYPES.WEAPON );
    end

    function self:getItem( type )
        for i = 1, #items do
            if items[i]:getItemType() == type then
                return items[i];
            end
        end
    end

    function self:getItems()
        return items;
    end

    function self:isEmpty()
        return #items == 0;
    end

    return self;
end

return Inventory;
