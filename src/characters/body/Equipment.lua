---
-- @module Equipment
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Observable = require( 'src.util.Observable' )
local ItemFactory = require( 'src.items.ItemFactory' )
local Container = require( 'src.items.Container' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Equipment = Observable:subclass( 'Equipment' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Equipment:initialize()
    Observable.initialize( self )

    self.slots = {}
end

function Equipment:addSlot( slot )
    local index = slot:getIndex()
    assert( not self.slots[index], 'ID already used! BodyParts have to be unique.' )
    self.slots[index] = slot
end

function Equipment:dropAllItems( tile )
    for _, slot in pairs( self.slots ) do
        if slot:containsItem() then
            local item = slot:getItem()
            if not item:isPermanent() then
                tile:getInventory():addItem( item )
            end
            slot:removeItem()
        end
    end
end

function Equipment:removeItem( slot )
    local item = slot:getItem()
    -- TODO search through item table.
    if item:isInstanceOf( Container ) then
        self:publish( 'CHANGE_VOLUME', -item:getCarryCapacity() )
    end

    slot:removeItem()
    return item
end

function Equipment:searchAndRemoveItem( item )
    for _, slot in pairs( self.slots ) do
        if item == slot:getItem() then
            return self:removeItem( slot )
        end
    end
end

function Equipment:addItem( slot, item )
    if slot:getItemType() == item:getItemType() then
        if not slot:getSubType() or slot:getSubType() == item:getSubType() then
            -- Notify observers of a volume change.
            if item:isInstanceOf( Container ) then
                self:publish( 'CHANGE_VOLUME', item:getCarryCapacity() )
            end

            slot:addItem( item )
            return true
        end
    end
    Log.warn( string.format( 'No applicable slot found for item %s', item:getID() ), 'Equipment' )
    return false
end

function Equipment:serialize()
    local t = {}
    for _, slot in pairs( self.slots ) do
        t[slot:getIndex()] = slot:serialize()
    end
    return t
end

function Equipment:load( savedEquipment )
    for index, slot in pairs( savedEquipment ) do
        if slot.item then
            self:addItem( self.slots[index], ItemFactory.loadItem( slot.item ))
        end
    end
end

---
-- Gets an item of the specified type without removing it from the inventory.
-- @param type (string) The type of item to get.
-- @return     (Item)   An item of the specified type.
--
function Equipment:getItem( type )
    for _, slot in pairs( self.slots ) do
        if slot:getItemType() == type then
            return slot:getItem()
        end
    end
end

function Equipment:getSlot( id )
    for _, slot in pairs ( self.slots ) do
        if slot:getID() == id then
            return slot
        end
    end
end

function Equipment:getSlots()
    return self.slots
end

return Equipment
