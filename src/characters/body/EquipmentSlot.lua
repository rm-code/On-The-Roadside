---
-- @module EquipmentSlot
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local EquipmentSlot = Class( 'EquipmentSlot' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function EquipmentSlot:initialize( index, id, itemType, subType, order )
    self.index = index
    self.id = id
    self.itemType = itemType
    self.subType = subType
    self.order = order
end

function EquipmentSlot:addItem( item )
    assert( item:getItemType() == self:getItemType(), "Item types do not match." )
    self.item = item
    return true
end

function EquipmentSlot:removeItem()
    assert( self.item ~= nil, "Can't remove item from an empty slot." )
    self.item = nil
end

function EquipmentSlot:serialize()
    local t = {}
    if self.item then
        t['item'] = self.item:serialize()
    end
    return t
end

function EquipmentSlot:containsItem()
    return self.item ~= nil
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function EquipmentSlot:getID()
    return self.id
end

function EquipmentSlot:getIndex()
    return self.index
end

function EquipmentSlot:getItem()
    return self.item
end

function EquipmentSlot:getItemType()
    return self.itemType
end

function EquipmentSlot:getSubType()
    return self.subType
end

function EquipmentSlot:getSortOrder()
    return self.order
end

return EquipmentSlot
