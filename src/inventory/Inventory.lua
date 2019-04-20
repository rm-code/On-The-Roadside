---
-- @module Inventory
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Log = require( 'src.util.Log' )
local Item = require( 'src.items.Item' )
local ItemStack = require( 'src.inventory.ItemStack' )
local ItemFactory = require( 'src.items.ItemFactory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Inventory = Class( 'Inventory' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ITEM_TYPES')
local DEFAULT_WEIGHT_LIMIT = 50
local DEFAULT_VOLUME_LIMIT = 50

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Returns the combined weight of all items in the inventory.
-- @tparam  table  items The table containing all items inside of this inventory.
-- @treturn number       The total weight of all items in the inventory.
--
local function calculateWeight( items )
    local weight = 0
    for _, item in ipairs( items ) do
        weight = weight + item:getWeight()
    end
    return weight
end

---
-- Returns the combined volume of all items in the inventory.
-- @tparam  table  items The table containing all items inside of this inventory.
-- @treturn number       The total volume of all items in the inventory.
--
local function calculateVolume( items )
    local volume = 0
    for _, item in ipairs( items ) do
        volume = volume + item:getVolume()
    end
    return volume
end

-- TODO: proper documentation
local function merge( self, stack, ostack )
    assert( stack:isInstanceOf( ItemStack ), 'Expected parameter of type ItemStack.' )
    assert( ostack:isInstanceOf( ItemStack ), 'Expected parameter of type ItemStack.' )

    for i = #ostack:getItems(), 1, -1 do
        local item = ostack:getItems()[i]

        if not self:doesFit( item:getWeight(), item:getVolume() ) then
            return false
        end

        stack:addItem( item )
        ostack:removeItem( item )
    end

    return true
end

---
-- Adds an ItemStack to the inventory.
-- @tparam  Inventory self  The inventory instance to use.
-- @tparam  ItemStack stack The ItemStack to add.
-- @tparam  number    index The index at which to insert the stack.
-- @treturn boolean         True if the ItemStack was added successfully.
--
local function addItemStack( self, stack, index )
    for i = 1, #self.items do
        if self.items[i]:getID() == stack:getID() then
            return merge( self, self.items[i], stack )
        end
    end
    table.insert( self.items, index, stack )
    return true
end

---
-- Adds a stackable item to the inventory. If the inventory already contains
-- an ItemStack for this Item's ID, it will be added to the existing stack.
-- If not, a new ItemStack for this item will be created.
-- @tparam  table   items The table containing all items inside of this inventory.
-- @tparam  Item    item  The stackable item to add.
-- @tparam  number  index The index at which to insert the item.
-- @treturn boolean       True if the item was added successfully.
--
local function addStackableItem( items, item, index )
    -- Check if we already have an item stack to add this item to.
    for _, stack in ipairs( items ) do
        if stack:getID() == item:getID() then
            stack:addItem( item )
            return true
        end
    end

    -- If not we create a new stack.
    local stack = ItemStack( item:getID() )
    stack:addItem( item )
    table.insert( items, index, stack )
    return true
end

---
-- Removes an Item from the inventory.
-- @tparam  table   items The table containing all items inside of this inventory.
-- @tparam  Item    item  The Item to remove.
-- @treturn boolean       True if the Item was removed successfully.
--
local function removeItem( items, item )
    for i = 1, #items do
        if items[i]:removeItem( item ) then
            -- Remove the stack if it is empty.
            if items[i]:isEmpty() then
                table.remove( items, i )
            end
            return true
        end
    end
    return false
end

---
-- Removes an ItemStack from the inventory.
-- @tparam  table items     The table containing all items inside of this inventory.
-- @tparam  stack ItemStack The ItemStack to remove.
-- @treturn       boolean   True if the ItemStack was removed successfully.
--
local function removeItemStack( items, stack )
    for i = 1, #items do
        if items[i] == stack then
            table.remove( items, i )
            return true
        end
    end
    return false
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Inventory:initialize( weightLimit, volumeLimit )
    self.weightLimit = weightLimit or DEFAULT_WEIGHT_LIMIT
    self.volumeLimit = volumeLimit or DEFAULT_VOLUME_LIMIT

    self.items = {}
end

---
-- Drops items until the volume of the carried items is smaller than the
-- maximum volume.
-- @tparam Inventory inventory The inventory to drop the items into.
--
function Inventory:dropItems( inventory )
    for i = #self.items, 1, -1 do
        if calculateVolume( self.items ) > self.volumeLimit then
            local success = inventory:addItem( self.items[i] )
            if success then
                self:removeItem( self.items[i] )
            else
                break
            end
        end
    end
end

---
-- Drops all items in the inventory with no regards of successfully adding
-- them to the target tile.
-- @tparam Tile tile The tile to drop the items on.
--
function Inventory:dropAllItems( tile )
    for i = #self.items, 1, -1 do
        tile:getInventory():addItem( self.items[i] )
        self:removeItem( self.items[i] )
    end
end

---
-- Checks if the item fits in the current inventory by checking the weight
-- and volume parameters.
-- @tparam  number  weight The weight of the item to check.
-- @tparam  number  volume The volume of the item to check.
-- @treturn boolean        Returns true if the item fits.
--
function Inventory:doesFit( weight, volume )
    return ( calculateWeight( self.items ) + weight < self.weightLimit ) and ( calculateVolume( self.items ) + volume < self.volumeLimit )
end

---
-- Adds an item to the inventory.
-- @tparam  Item    item  The item to add.
-- @tparam  number  index The index at which to insert the item (optional).
-- @treturn boolean       True if the item was added successfully.
--
function Inventory:addItem( item, index )
    index = index or ( #self.items + 1 )

    if not self:doesFit( item:getWeight(), item:getVolume() ) then
        Log.warn( 'Item doesn\'t fit into the inventory.', 'Inventory' )
        return false
    end

    if item:isInstanceOf( ItemStack ) then
        return addItemStack( self, item, index )
    end

    if item:isInstanceOf( Item ) then
        return addStackableItem( self.items, item, index )
    end
end

---
-- Inserts an item at the position of another item.
-- @tparam  Item    item  The item to insert.
-- @tparam  Item    oitem The item to use as the position.
-- @treturn boolean       True if the item was inserted successfully
--
function Inventory:insertItem( item, oitem )
    for i = 1, #self.items do
        if self.items[i] == oitem then
            if item:isInstanceOf( ItemStack ) and oitem:isInstanceOf( ItemStack ) and oitem:getID() == item:getID() then
                return merge( self, oitem, item )
            end
            return self:addItem( item, i )
        end
    end
end

---
-- Removes an item from the inventory.
-- @tparam  Item    item The item to remove.
-- @treturn boolean      True if the item was removed successfully.
--
function Inventory:removeItem( item )
    if item:isInstanceOf( ItemStack ) then
        return removeItemStack( self.items, item )
    end

    if item:isInstanceOf( Item ) then
        return removeItem( self.items, item )
    end
end

---
-- Serializes the inventory.
-- @treturn table The serialized object.
--
function Inventory:serialize()
    local t = {}
    for i = 1, #self.items do
        table.insert( t, self.items[i]:serialize() )
    end
    return t
end

---
-- Loads items.
--
function Inventory:loadItems( loadedItems )
    for _, item in pairs( loadedItems ) do
        for _, sitem in ipairs( item.items ) do
            self:addItem( ItemFactory.loadItem( sitem ))
        end
    end
end

---
-- Checks if the inventory contains a certain type of item.
-- @tparam  string  type The type to check for.
-- @treturn boolean      True if an item of the specified type was found.
--
function Inventory:containsItemType( type )
    for i = 1, #self.items do
        if self.items[i]:getItemType() == type then
            return true
        end
    end
    return false
end

---
-- Gets an item of the specified type and removes it from the inventory.
-- @tparam  string type The type of item to remove.
-- @treturn Item        An item of the specified type.
--
function Inventory:getAndRemoveItem( type )
    for _, stack in ipairs( self.items ) do
        if stack:getItemType() == type then
            local item = stack:getItem()
            self:removeItem( item )
            return item
        end
    end
end

---
-- Receives events.
-- @tparam string  event The received event.
-- @tparam varargs ...   Variable arguments.
--
function Inventory:receive( event, ... )
    if event == 'CHANGE_VOLUME' then
        local delta = ...
        self.volumeLimit = self.volumeLimit + delta
    end
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Gets an item of type weapon.
-- @treturn Weapon The weapon item.
--
function Inventory:getWeapon()
    return self:getItem( ITEM_TYPES.WEAPON )
end

---
-- Gets an item of the specified type without removing it from the inventory.
-- @tparam  string type The type of item to get.
-- @treturn Item        An item of the specified type.
--
function Inventory:getItem( type )
    for i = 1, #self.items do
        if self.items[i]:getItemType() == type then
            return self.items[i]
        end
    end
end

---
-- Gets the table of items this inventory contains.
-- @treturn table A sequence containing the items and stacks in this inventory.
--
function Inventory:getItems()
    return self.items
end

---
-- Checks if the inventory is empty.
-- @treturn boolean True if the inventory doesn't contain any items or stacks.
--
function Inventory:isEmpty()
    return #self.items == 0
end

---
-- Gets the used weight for this inventory.
-- @treturn number The weight for this inventory.
--
function Inventory:getWeight()
    return calculateWeight( self.items )
end

---
-- Gets the current volume for this inventory.
-- @treturn number The volume for this inventory.
--
function Inventory:getVolume()
    return calculateVolume( self.items )
end

---
-- Gets the weight limit for this inventory.
-- @treturn number The weight limit for this inventory.
--
function Inventory:getWeightLimit()
    return self.weightLimit
end

---
-- Gets the volume limit for this inventory.
-- @treturn number The volume limit for this inventory.
--
function Inventory:getVolumeLimit()
    return self.volumeLimit
end

return Inventory
