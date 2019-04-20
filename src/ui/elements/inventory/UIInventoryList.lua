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

---
-- Creates the storage info which shows details about the weight and volume stats
-- of the creature's inventory.
--
local function generateStorageInfo( self )
    local infoText = string.format( 'W: %0.1f/%0.1f V: %0.1f/%0.1f', self.inventory:getWeight(), self.inventory:getWeightLimit(), self.inventory:getVolume(), self.inventory:getVolumeLimit() )
    self:addChild( UILabel( self.ax, self.ay, 0, 0, self.w, 1, infoText, 'ui_text_dim' ))
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new UIInventoryList instance.
--
function UIInventoryList:initialize( px, py, x, y, w, h, inventory )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.inventory = inventory
    self:refresh()
end

---
-- Recreates the inventory list.
--
function UIInventoryList:refresh()
    populateItemList( self )
    generateStorageInfo( self )
end

---
-- Draws the inventory list.
--
function UIInventoryList:draw()
    for _, item in ipairs( self.children ) do
        item:draw()
    end
end

function UIInventoryList:drag( rmb, fullstack )
    for _, uiItem in ipairs( self.children ) do
        if uiItem:isInstanceOf( UIInventoryItem ) and uiItem:isMouseOver() then
            local item = uiItem:drag( rmb, fullstack )
            self.inventory:removeItem( item )
            self:refresh()
            return item
        end
    end
end

function UIInventoryList:splitStack()
    for _, uiItem in ipairs( self.children ) do
        if uiItem:isInstanceOf( UIInventoryItem ) and uiItem:isMouseOver() then
            local item = uiItem:splitStack()
            self.inventory:removeItem( item )
            self:refresh()
            return item
        end
    end
end

function UIInventoryList:drop( item )
    for _, uiItem in ipairs( self.children ) do
        if uiItem:isInstanceOf( UIInventoryItem ) and uiItem:isMouseOver() then
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

---
-- Returns the Item the mouse cursor is currently over. Note that the Item is
-- actually wrapped into an UIInventoryItem.
-- @treturn Item The item under the mouse cursor.
--
function UIInventoryList:getItemBelowCursor()
    for _, uiItem in ipairs( self.children ) do
        if uiItem:isInstanceOf( UIInventoryItem ) and uiItem:isMouseOver() then
            return uiItem:getItem()
        end
    end
end

---
-- Checks if an item fits into the creature's inventory.
-- @tparam  Item    item The item to check for.
-- @treturn boolean      True if the item fits, false otherwise.
--
function UIInventoryList:doesFit( item )
    return self.inventory:doesFit( item:getWeight(), item:getVolume() )
end

return UIInventoryList
