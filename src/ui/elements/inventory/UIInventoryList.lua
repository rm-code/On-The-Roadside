---
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

local function populateItemList( self )
    local nList = {}
    for offset, item in ipairs( self.inventory:getItems() ) do
        -- Spawn elements at the list's position but offset them vertically.
        local uiItem = UIInventoryItem( self.ax, self.ay, 0, offset, self.w, 1, item )
        self:addChild( uiItem )
        nList[#nList + 1] = uiItem
    end
    return nList
end

local function generateStorageInfo( self )
    local infoText = string.format( 'W: %0.1f/%0.1f V: %0.1f/%0.1f', self.inventory:getWeight(), self.inventory:getWeightLimit(), self.inventory:getVolume(), self.inventory:getVolumeLimit() )
    local info = UILabel( self.ax, self.ay, 0, 0, self.w, 1, infoText, 'ui_text_dim' )
    self:addChild( info )
    return info
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
    self.list = populateItemList( self )
    self.info = generateStorageInfo( self )
end

function UIInventoryList:draw()
    for _, item in ipairs( self.list ) do
        item:draw()
    end
    self.info:draw()
end

function UIInventoryList:drag( rmb, fullstack )
    for _, uiItem in ipairs( self.list ) do
        if uiItem:isMouseOver() then
            local item = uiItem:drag( rmb, fullstack )
            self.inventory:removeItem( item )
            self:refresh()
            return item
        end
    end
end

function UIInventoryList:drop( item )
    for _, uiItem in ipairs( self.list ) do
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
    for _, uiItem in ipairs( self.list ) do
        if uiItem:isMouseOver() then
            return uiItem:getItem()
        end
    end
end

function UIInventoryList:doesFit( item )
    return self.inventory:doesFit( item:getWeight(), item:getVolume() )
end

return UIInventoryList
