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

local UIInventoryList = {}

function UIInventoryList.new( px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UIInventoryList' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local list
    local inventory
    local info

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function populateItemList()
        local nList = {}
        for offset, item in ipairs( inventory:getItems() ) do
            -- Spawn elements at the list's position but offset them vertically.
            local uiItem = UIInventoryItem.new( item, self.ax, self.ay, 0, offset, self.w, 1 )
            uiItem:init()
            self:addChild( uiItem )
            nList[#nList + 1] = uiItem
        end
        return nList
    end

    local function generateStorageInfo()
        local infoText = string.format( 'W: %0.1f/%0.1f V: %0.1f/%0.1f', inventory:getWeight(), inventory:getWeightLimit(), inventory:getVolume(), inventory:getVolumeLimit() )
        info = UILabel.new( self.ax, self.ay, 0, 0, self.w, 1, infoText, 'ui_text_dim' )
        self:addChild( info )
        return info
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:refresh()
        list = populateItemList()
        info = generateStorageInfo()
    end

    function self:init( ninventory )
        inventory = ninventory
        self:refresh()
    end

    function self:draw()
        for _, item in ipairs( list ) do
            item:draw()
        end

        info:draw()
    end

    function self:drag( rmb, fullstack )
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() then
                local item = uiItem:drag( rmb, fullstack )
                inventory:removeItem( item )
                self:refresh()
                return item
            end
        end
    end

    function self:drop( item )
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() then
                local success = inventory:insertItem( item, uiItem:getItem() )
                if success then
                    self:refresh()
                    return true
                end
            end
        end

        local success = inventory:addItem( item )
        if success then
            self:refresh()
            return true
        end
        return false
    end

    function self:getItemBelowCursor()
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() then
                return uiItem:getItem()
            end
        end
    end

    function self:doesFit( item )
        return inventory:doesFit( item:getWeight(), item:getVolume() )
    end

    return self
end

return UIInventoryList
