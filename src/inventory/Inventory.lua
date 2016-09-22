local Object = require( 'src.Object' );
local ItemStack = require( 'src.inventory.ItemStack' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Inventory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ItemTypes');
local DEFAULT_WEIGHT_LIMIT = 50;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Inventory.new( weightLimit )
    local self = Object.new():addInstance( 'Inventory' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local items = {};
    weightLimit = weightLimit or DEFAULT_WEIGHT_LIMIT;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Returns the combined weight of all items in the inventory.
    -- @return (number) The total weight of all items in the inventory.
    --
    local function calculateWeight()
        local weight = 0;
        for _, item in ipairs( items ) do
            weight = weight + item:getWeight();
        end
        return weight;
    end

    ---
    -- Adds an Item to the inventory.
    -- @param item  (Item)    The Item to add.
    -- @param index (number)  The index at which to insert the item.
    -- @return      (boolean) True if the Item was added successfully.
    --
    local function addItem( item, index )
        table.insert( items, index, item );
        return true;
    end

    ---
    -- Adds an ItemStack to the inventory.
    -- @param stack (ItemStack) The ItemStack to add.
    -- @param index (number)    The index at which to insert the stack.
    -- @return      (boolean)   True if the ItemStack was added successfully.
    --
    local function addItemStack( stack, index )
        table.insert( items, index, stack );
        return true;
    end

    ---
    -- Adds a stackable item to the inventory. If the inventory already contains
    -- an ItemStack for this Item's ID, it will be added to the existing stack.
    -- If not, a new ItemStack for this item will be created.
    -- @param item  (Item)    The stackable item to add.
    -- @param index (number)  The index at which to insert the item.
    -- @return      (boolean) True if the item was added successfully.
    --
    local function addStackableItem( item, index )
        -- Check if we already have an item stack to add this item to.
        for _, stack in ipairs( items ) do
            if stack:instanceOf( 'ItemStack' ) and stack:getID() == item:getID() then
                stack:addItem( item );
                return true;
            end
        end

        -- If not we create a new stack.
        local stack = ItemStack.new( item:getID() );
        stack:addItem( item );
        table.insert( items, index, stack );
        return true;
    end

    ---
    -- Removes an Item from the inventory.
    -- @param item (Item)    The Item to remove.
    -- @return     (boolean) True if the Item was removed successfully.
    --
    local function removeItem( item )
        for i = 1, #items do
            -- Check if item is part of a stack.
            if items[i]:instanceOf( 'ItemStack' ) then
                local success = items[i]:removeItem( item );
                if success then
                    -- Remove the stack if it is empty.
                    if items[i]:isEmpty() then
                        table.remove( items, i );
                    end
                    return true;
                end
            elseif items[i] == item then
                table.remove( items, i );
                return true;
            end
        end
        return false;
    end

    ---
    -- Removes an ItemStack from the inventory.
    -- @param stack (ItemStack) The ItemStack to remove.
    -- @return      (boolean)   True if the ItemStack was removed successfully.
    --
    local function removeItemStack( stack )
        for i = 1, #items do
            if items[i]:instanceOf( 'ItemStack' ) and items[i] == stack then
                table.remove( items, i );
                return true;
            end
        end
        return false;
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Adds an item to the inventory.
    -- @param item  (Item)    The item to add.
    -- @param index (number)  The index at which to insert the item (optional).
    -- @return      (boolean) True if the item was added successfully.
    --
    function self:addItem( item, index )
        index = index or ( #items + 1 );

        local weight = calculateWeight();
        if weight + item:getWeight() > weightLimit then
            return false;
        end

        if item:instanceOf( 'ItemStack' ) then
            return addItemStack( item, index );
        end

        if item:instanceOf( 'Item' ) then
            if item:isStackable() then
                return addStackableItem( item, index );
            else
                return addItem( item, index );
            end
        end
    end

    ---
    -- Inserts an item at the position of another item.
    -- @param item  (Item)    The item to insert.
    -- @param oitem (Item)    The item to use as the position.
    -- @return      (boolean) True if the item was inserted successfully;
    --
    function self:insertItem( item, oitem )
        for i = 1, #items do
            if items[i] == oitem then
                return self:addItem( item, i );
            end
        end
    end

    ---
    -- Removes an item from the inventory.
    -- @param item (Item)    The item to remove.
    -- @return     (boolean) True if the item was removed successfully.
    --
    function self:removeItem( item )
        if item:instanceOf( 'ItemStack' ) then
            return removeItemStack( item );
        end

        if item:instanceOf( 'Item') then
            return removeItem( item );
        end
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

    ---
    -- Gets an item of the specified type and removes it from the inventory.
    -- @param type (string) The type of item to remove.
    -- @return     (Item)   An item of the specified type.
    --
    function self:getAndRemoveItem( type )
        for _, item in ipairs( items ) do
            if item:getItemType() == type then
                if item:instanceOf( 'ItemStack' ) then
                    local i = item:getItem();
                    self:removeItem( i );
                    return i;
                else
                    self:removeItem( item );
                    return item;
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Gets an item of type bag.
    -- @return (Bag) The bag item.
    --
    function self:getBackpack()
        return self:getItem( ITEM_TYPES.BAG );
    end

    ---
    -- Gets an item of type weapon.
    -- @return (Weapon) The weapon item.
    --
    function self:getWeapon()
        return self:getItem( ITEM_TYPES.WEAPON );
    end

    ---
    -- Gets an item of the specified type without removing it from the inventory.
    -- @param type (string) The type of item to get.
    -- @return     (Item)   An item of the specified type.
    --
    function self:getItem( type )
        for i = 1, #items do
            if items[i]:getItemType() == type then
                return items[i];
            end
        end
    end

    ---
    -- Gets the table of items this inventory contains.
    -- @return (table) A sequence containing the items and stacks in this inventory.
    --
    function self:getItems()
        return items;
    end

    ---
    -- Checks if the inventory is empty.
    -- @return (boolean) True if the inventory doesn't contain any items or stacks.
    --
    function self:isEmpty()
        return #items == 0;
    end

    ---
    -- Gets the weight limit for this inventory.
    -- @return (number) The weight limit for this inventory.
    --
    function self:getWeightLimit()
        return weightLimit;
    end

    return self;
end

return Inventory;
