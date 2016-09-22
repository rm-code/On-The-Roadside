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

    local function calculateWeight()
        local weight = 0;
        for _, item in ipairs( items ) do
            weight = weight + item:getWeight();
        end
        return weight;
    end

    local function addStackableItem( item )
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
        items[#items + 1] = stack;
        return true;
    end

    local function addItemStack( stack )
        items[#items + 1] = stack;
        return true;
    end

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
    -- @param item (Item)    The item to add.
    -- @return     (boolean) True if the item was added successfully.
    --
    function self:addItem( item )
        local weight = calculateWeight();
        if weight + item:getWeight() > weightLimit then
            return false;
        end

        if item:instanceOf( 'ItemStack' ) then
            return addItemStack( item );
        end

        if item:isStackable() then
            return addStackableItem( item );
        end

        items[#items + 1] = item;
        return true;
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

        for i = 1, #items do
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

    function self:getWeightLimit()
        return weightLimit;
    end

    return self;
end

return Inventory;
