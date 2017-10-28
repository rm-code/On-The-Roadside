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

local UIEquipmentList = {}

function UIEquipmentList.new( px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UIEquipmentList' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local character
    local equipment
    local list

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Iterates over all equipment slots an UIEquipmentSlot for them and stores
    -- them based on their sort order.
    -- @treturn table A sequence containing the UIEquipmentSlots.
    --
    local function populateItemList()
        local nList = {}
        for _, slot in pairs( equipment:getSlots() ) do
            local uiItem = UIEquipmentSlot.new( self.ax, self.ay, 0, slot:getSortOrder(), self.w, 1 )
            uiItem:init( slot )
            nList[slot:getSortOrder()] = uiItem
        end
        return nList
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Recreates the item list.
    --
    function self:refresh()
        list = populateItemList()
    end

    ---
    -- Initialises the UIEquipmentList.
    -- @tparam Character character The character to create the equipment list for.
    --
    function self:init( ncharacter )
        character = ncharacter
        equipment = character:getEquipment()
        self:refresh()
    end

    ---
    -- Draws the list.
    --
    function self:draw()
        for _, slot in ipairs( list ) do
            slot:draw()
        end
    end

    ---
    -- Drags an item below the mouse cursor.
    -- @treturn UIEquipmentSlot The UIEquipmentSlot containing the actual item.
    --
    function self:drag()
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() and uiItem:getSlot():containsItem() and not uiItem:getSlot():getItem():isPermanent() then
                local item = equipment:removeItem( uiItem:getSlot() )

                if item:instanceOf( 'Container' ) then
                    character:getInventory():dropItems( character:getTile() )
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
    function self:drop( item, origin )
        -- Stacks and unequippable items can't be dropped on equipment lists.
        if item:instanceOf( 'ItemStack' ) or not item:isEquippable() then
            return false
        end

        local success = false
        for _, uiItem in ipairs( list ) do
            local slot = uiItem:getSlot()
            if uiItem:isMouseOver() and item:isSameType( slot:getItemType(), slot:getSubType() ) then
                if slot:containsItem() then
                    local tmp = equipment:removeItem( slot )
                    success = equipment:addItem( slot, item )
                    origin:drop( tmp )
                else
                    success = equipment:addItem( slot, item )
                end
            end
        end

        self:refresh()
        return success
    end

    function self:getSlotBelowCursor()
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() then
                return uiItem:getSlot()
            end
        end
    end

    function self:getItemBelowCursor()
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() then
                return uiItem:getSlot():getItem()
            end
        end
    end

    function self:highlight( nitem )
        for _, uiItem in ipairs( list ) do
            uiItem:highlight( nitem )
        end
    end

    function self:doesFit( item )
        local slot = self:getSlotBelowCursor()
        if not slot then
            return false
        end
        return item:isSameType( slot:getItemType(), slot:getSubType() )
    end

    return self
end

return UIEquipmentList
