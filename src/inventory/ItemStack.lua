---
-- @module ItemStack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ItemStack = Class( 'ItemStack' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function ItemStack:initialize( id )
    if not id or type( id ) ~= 'string' then
        error( 'Expected a parameter of type "string".' )
    end

    self.id = id
    self.items = {}
end

function ItemStack:addItem( item )
    assert( item:getID() == self.id, 'ID doesn\'t fit the stack' )
    self.items[#self.items + 1] = item
    return true
end

function ItemStack:removeItem( item )
    for i = 1, #self.items do
        if self.items[i] == item then
            table.remove( self.items, i )
            return true
        end
    end
    return false
end

function ItemStack:getWeight()
    local weight = 0
    for i = 1, #self.items do
        weight = weight + self.items[i]:getWeight()
    end
    return weight
end

function ItemStack:getVolume()
    local volume = 0
    for i = 1, #self.items do
        volume = volume + self.items[i]:getVolume()
    end
    return volume
end

function ItemStack:split()
    if #self.items > 1 then
        local count = math.floor( #self.items * 0.5 )
        local newStack = ItemStack( self.id )
        for i = 1, count do
            newStack:addItem( self.items[i] )
            self:removeItem( self.items[i] )
        end
        return newStack
    end
    return self
end

function ItemStack:serialize()
    local t = {
        ['ItemStack'] = true,
        ['id'] = self.id,
        ['items'] = {}
    }
    for i = 1, #self.items do
        t['items'][i] = self.items[i]:serialize()
    end
    return t
end

function ItemStack:isSameType( itemType, subType )
    return self.items[#self.items]:isSameType( itemType, subType )
end

function ItemStack:getItem()
    return self.items[#self.items]
end

function ItemStack:getItems()
    return self.items
end

function ItemStack:getItemType()
    return self.items[#self.items]:getItemType()
end

function ItemStack:getSubType()
    return self.items[#self.items]:getSubType()
end

function ItemStack:getDescriptionID()
    return self.items[#self.items]:getDescriptionID()
end

function ItemStack:getID()
    return self.id
end

function ItemStack:getItemCount()
    return #self.items
end

function ItemStack:isEmpty()
    return #self.items == 0
end

return ItemStack
