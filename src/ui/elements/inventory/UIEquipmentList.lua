---
-- @module UIEquipmentList
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local UIEquipmentSlot = require( 'src.ui.elements.inventory.UIEquipmentSlot' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIEquipmentList = UIElement:subclass( 'UIEquipmentList' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Iterates over all equipment slots an UIEquipmentSlot for them and stores
-- them based on their sort order.
-- @treturn table A sequence containing the UIEquipmentSlots.
--
local function populateItemList( self )
    local nList = {}
    for _, slot in pairs( self.equipment:getSlots() ) do
        local uiItem = UIEquipmentSlot( self.ax, self.ay, 0, slot:getSortOrder(), self.w, 1, slot )
        nList[slot:getSortOrder()] = uiItem
        self:addChild( uiItem )
    end
    return nList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new UIEquipmentList instance.
--
function UIEquipmentList:initialize( px, py, x, y, w, h, character )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.character = character
    self.equipment = character:getEquipment()
    self:refresh()
end

---
-- Recreates the item list.
--
function UIEquipmentList:refresh()
    self.list = populateItemList( self )
end

---
-- Draws the list.
--
function UIEquipmentList:draw()
    for _, slot in ipairs( self.list ) do
        slot:draw()
    end
end

---
-- Drags an item below the mouse cursor.
-- @treturn UIEquipmentSlot The UIEquipmentSlot containing the actual item.
--
function UIEquipmentList:drag()
    for _, uiItem in ipairs( self.list ) do
        if uiItem:isMouseOver() and uiItem:getSlot():containsItem() and not uiItem:getSlot():getItem():isPermanent() then
            local item = self.equipment:removeItem( uiItem:getSlot() )

            if item:instanceOf( 'Container' ) then
                self.character:getInventory():dropItems( self.character:getTile() )
            end

            self:refresh()
            return item, uiItem:getSlot()
        end
    end
end

---
-- Drops an item onto this list. If the slot the item belongs to already
-- contains an item, that item will be swapped to the inventory the new item
-- is coming from.
-- @tparam Item            item   The new item to place in an equipment slot.
-- @tparam UIInventoryList origin The inventory list the item is coming from.
-- @treturn boolean        Wether or not the drop action was succesful.
--
function UIEquipmentList:drop( item, origin )
    -- Stacks and unequippable items can't be dropped on equipment lists.
    if item:instanceOf( 'ItemStack' ) or not item:isEquippable() then
        return false
    end

    local success = false
    for _, uiItem in ipairs( self.list ) do
        local slot = uiItem:getSlot()
        if uiItem:isMouseOver() and item:isSameType( slot:getItemType(), slot:getSubType() ) then
            if slot:containsItem() then
                local tmp = self.equipment:removeItem( slot )
                success = self.equipment:addItem( slot, item )
                origin:drop( tmp )
            else
                success = self.equipment:addItem( slot, item )
            end
        end
    end

    self:refresh()
    return success
end

function UIEquipmentList:getSlotBelowCursor()
    for _, uiItem in ipairs( self.list ) do
        if uiItem:isMouseOver() then
            return uiItem:getSlot()
        end
    end
end

function UIEquipmentList:getItemBelowCursor()
    for _, uiItem in ipairs( self.list ) do
        if uiItem:isMouseOver() then
            return uiItem:getSlot():getItem()
        end
    end
end

function UIEquipmentList:highlight( nitem )
    for _, uiItem in ipairs( self.list ) do
        uiItem:matchesType( nitem )
    end
end

function UIEquipmentList:doesFit( item )
    local slot = self:getSlotBelowCursor()
    if not slot then
        return false
    end
    return item:isSameType( slot:getItemType(), slot:getSubType() )
end

return UIEquipmentList
