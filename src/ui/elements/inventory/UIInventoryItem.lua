---
-- @module UIInventoryItem
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UITranslatedLabel = require( 'src.ui.elements.UITranslatedLabel' )
local UILabel = require( 'src.ui.elements.UILabel' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIInventoryItem = {}

function UIInventoryItem.new( item, px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UIInventoryItem' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local background
    local label
    local amount

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function updateBackground()
        if self:isMouseOver() then
            background:setColor( 'ui_equipment_mouseover' )
        else
            background:setColor( 'sys_background' )
        end
    end

    local function createInfo()
        local count = 1
        if item:instanceOf( 'ItemStack' ) and item:getItemCount() > 1 then
            count = item:getItemCount()
        end
        amount = UILabel.new( self.ax, self.ay, self.w-2, 0, self.w, 1, count, 'ui_equipment_item' )
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        background = UIBackground.new( self.ax, self.ay, 0, 0, self.w, self.h )
        label = UITranslatedLabel.new( self.ax, self.ay, 0, 0, self.w, 1, item:getID(), 'ui_equipment_item' )

        createInfo()
    end

    function self:draw()
        updateBackground()
        background:draw()

        label:draw()
        amount:draw()
    end

    function self:drag( rmb, fullstack )
        if item:instanceOf( 'ItemStack' ) and rmb then
            if item:getItemCount() == 1 then
                return item
            else
                return item:split()
            end
        elseif item:instanceOf( 'ItemStack' ) and not fullstack then
            return item:getItem()
        end
        return item
    end

    function self:getItem()
        return item
    end

    function self:hasItem()
        return item ~= nil
    end

    return self
end

return UIInventoryItem
