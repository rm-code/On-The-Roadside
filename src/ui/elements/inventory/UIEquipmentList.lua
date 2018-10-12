---
-- The UIEquipmentList is a specialised list on the inventory screen that takes
-- care of drawing a creature's equipment slots and the equipped items therein.
--
-- @module UIEquipmentList
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local UIEquipmentSlot = require( 'src.ui.elements.inventory.UIEquipmentSlot' )
local Container = require( 'src.items.Container' )
local ItemStack = require( 'src.inventory.ItemStack' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIEquipmentList = UIElement:subclass( 'UIEquipmentList' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Creates UIEquipmentSlots for each EquipmentSlot in a creature's body and
-- stores it in a list.
-- @treturn table A sequence containing the UIEquipmentSlots.
--
local function populateItemList( self )
    -- Clear current children.
    self.children = {}

    -- Iterate over all equipment slots in the creature's body.
    for _, slot in pairs( self.equipment:getSlots() ) do
        -- Map each slot to a UIEquipmentSlot object.
        local uiEquipmentSlot = UIEquipmentSlot( self.ax, self.ay, 0, slot:getSortOrder(), self.w, 1, slot )

        -- Add the UIEquipmentSlot to the list's children (@see UIElement) and
        -- use its sort order to find the correct position.
        self:addChild( uiEquipmentSlot, slot:getSortOrder() )
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new UIEquipmentList instance.
--
function UIEquipmentList:initialize( px, py, x, y, w, h, character, dropInventory )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.character = character
    self.dropInventory = dropInventory

    self.equipment = character:getEquipment()
    self:refresh()
end

---
-- Recreates the equipment list.
--
function UIEquipmentList:refresh()
    populateItemList( self )
end

---
-- Draws the equipment slots.
--
function UIEquipmentList:draw()
    for _, uiEquipmentSlot in ipairs( self.children ) do
        uiEquipmentSlot:draw()
    end
end

---
-- Drags an item below the mouse cursor.
-- @treturn UIEquipmentSlot The UIEquipmentSlot containing the actual item.
--
function UIEquipmentList:drag()
    for _, uiEquipmentSlot in ipairs( self.children ) do
        if uiEquipmentSlot:isMouseOver()
        and uiEquipmentSlot:getSlot():containsItem()
        and not uiEquipmentSlot:getSlot():getItem():isPermanent() then
            local item = self.equipment:removeItem( uiEquipmentSlot:getSlot() )

            if item:isInstanceOf( Container ) then
                self.character:getInventory():dropItems( self.dropInventory )
            end

            self:refresh()
            return item, self.equipment, uiEquipmentSlot:getSlot()
        end
    end
end

---
-- Since slots on the UIEquipmentList can't contain stacks, we simply delegate
-- the call to the dragging method which returns the correct objects.
--
function UIEquipmentList:splitStack()
    return self:drag()
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
    if item:isInstanceOf( ItemStack ) or not item:isEquippable() then
        return false
    end

    local success = false
    for _, uiEquipmentSlot in ipairs( self.children ) do
        local slot = uiEquipmentSlot:getSlot()
        if uiEquipmentSlot:isMouseOver() and item:isSameType( slot:getItemType(), slot:getSubType() ) then
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

---
-- Returns the equipment slot the mouse is currently hovering over.
-- @treturn UIEquipmentSlot The slot the mouse is currently over.
--
function UIEquipmentList:getSlotBelowCursor()
    for _, uiEquipmentSlot in ipairs( self.children ) do
        if uiEquipmentSlot:isMouseOver() then
            return uiEquipmentSlot:getSlot()
        end
    end
end

---
-- Returns the equipment item the mouse is currently hovering over. Note that
-- the item is actually located within the EquipmentSlot object which itself
-- is wrapped inside of a UIEquipmentSlot instance.
-- @treturn Item The item the mouse is currently over.
--
function UIEquipmentList:getItemBelowCursor()
    for _, uiEquipmentSlot in ipairs( self.children ) do
        if uiEquipmentSlot:isMouseOver() then
            return uiEquipmentSlot:getSlot():getItem()
        end
    end
end

---
-- Highlights the UIEquipmentSlot(s) in which the specified Item fits.
-- @tparam Item nitem The item to highlight slots for.
--
function UIEquipmentList:highlight( nitem )
    for _, uiEquipmentSlot in ipairs( self.children ) do
        uiEquipmentSlot:highlight( nitem )
    end
end

---
-- Checks if an item fits into the UIEquipmentSlot currently located under the
-- mouse cursor. If the mouse isn't hovering over a slot the function returns
-- false.
-- @tparam  Item    item The item to check for.
-- @treturn boolean      True if the item fits. False if it doesn't or the mouse isn't
--                        hovering over an UIEquipmentSlot.
--
function UIEquipmentList:doesFit( item )
    local uiEquipmentSlot = self:getSlotBelowCursor()
    if not uiEquipmentSlot then
        return false
    end
    return item:isSameType( uiEquipmentSlot:getItemType(), uiEquipmentSlot:getSubType() )
end

return UIEquipmentList
