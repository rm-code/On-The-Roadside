---
-- The UIInventoryList is a specialised list on the inventory screen that takes
-- care of drawing all items a creature currently carries around in its invenory.
--
-- @module UIInventoryList
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local UIInventoryItem = require( 'src.ui.elements.inventory.UIInventoryItem' )
local UILabel = require( 'src.ui.elements.UILabel' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIInventoryList = UIElement:subclass( 'UIInventoryList' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Creates UIInventoryItems for each Item in a creature's inventory and
-- stores it as a children of the UIInventoryList.
-- @treturn table A sequence containing the UIInventoryItems.
--
local function populateItemList( self )
    -- Clear current children.
    self.children = {}

    -- Iterate over all items in the creature's inventory.
    for offset, item in ipairs( self.inventory:getItems() ) do
        -- Map each Item to an UIInventoryItem object. The UIInventoryItem is spawned at the
        -- UIInventoryList's absolute position but offset vertically based on its positon in
        -- the inventory.
        local uiInventoryItem = UIInventoryItem( self.ax, self.ay, 0, offset, self.w, 1, item )
        self:addChild( uiInventoryItem )
    end
end

local function generateStorageInfo( self )
    local infoText = string.format( 'W: %0.1f/%0.1f V: %0.1f/%0.1f', self.inventory:getWeight(), self.inventory:getWeightLimit(), self.inventory:getVolume(), self.inventory:getVolumeLimit() )
    self:addChild( UILabel( self.ax, self.ay, 0, 0, self.w, 1, infoText, 'ui_text_dim' ))
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new UIEquipmentList instance.
--
function UIInventoryList:initialize( px, py, x, y, w, h, inventory )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.inventory = inventory
    self:refresh()
end

function UIInventoryList:refresh()
    populateItemList( self )
    generateStorageInfo( self )
end

function UIInventoryList:draw()
    for _, item in ipairs( self.children ) do
        item:draw()
    end
end

function UIInventoryList:drag( rmb, fullstack )
    for _, uiItem in ipairs( self.children ) do
        if uiItem:isMouseOver() then
            local item = uiItem:drag( rmb, fullstack )
            self.inventory:removeItem( item )
            self:refresh()
            return item
        end
    end
end

function UIInventoryList:drop( item )
    for _, uiItem in ipairs( self.children ) do
        if uiItem:isMouseOver() then
            local success = self.inventory:insertItem( item, uiItem:getItem() )
            if success then
                self:refresh()
                return true
            end
        end
    end

    local success = self.inventory:addItem( item )
    if success then
        self:refresh()
        return true
    end
    return false
end

function UIInventoryList:getItemBelowCursor()
    for _, uiItem in ipairs( self.children ) do
        if uiItem:isMouseOver() then
            return uiItem:getItem()
        end
    end
end

function UIInventoryList:doesFit( item )
    return self.inventory:doesFit( item:getWeight(), item:getVolume() )
end

return UIInventoryList
