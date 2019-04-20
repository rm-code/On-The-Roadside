---
-- @module Item
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Item = Class( 'Item' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Item:initialize( template )
    self.id = template.id
    self.descriptionID = template.idDesc
    self.itemType = template.itemType
    self.subType = template.subType
    self.weight = template.weight
    self.volume = template.volume
    self.equippable = template.equippable
    self.permanent = template.permanent
end

function Item:getID()
    return self.id
end

function Item:getDescriptionID()
    return self.descriptionID or 'default_item_description'
end

function Item:getItemType()
    return self.itemType
end

function Item:getSubType()
    return self.subType
end

function Item:isSameType( itemType, subType )
    if self.itemType == itemType then
        if not subType or subType == self.subType then
            return true
        end
    end
    return false
end

function Item:getWeight()
    return self.weight
end

function Item:getVolume()
    return self.volume
end

function Item:isEquippable()
    return self.equippable
end

function Item:isPermanent()
    return self.permanent
end

function Item:serialize()
    local t = {
        ['id'] = self.id,
        ['itemType'] = self.itemType
    }
    return t
end

return Item
