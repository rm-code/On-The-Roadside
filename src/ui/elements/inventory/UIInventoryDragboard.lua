---
-- @module UIInventoryDragboard
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Observable = require( 'src.util.Observable' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Translator = require( 'src.util.Translator' )
local GridHelper = require( 'src.util.GridHelper' )
local UIBackground = require( 'src.ui.elements.UIBackground' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIInventoryDragboard = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_WIDTH = 20

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIInventoryDragboard.new()
    local self = Observable.new():addInstance( 'UIInventoryDragboard' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local background = UIBackground( 0, 0, 0, 0, ITEM_WIDTH, 1 )
    local dragContext

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function returnItemToOrigin( item, origin )
        -- TODO Hack to bridge gap between middleclass and old oop.
        if origin.instanceOf and origin:instanceOf( 'EquipmentSlot' ) then
            origin:addItem( item )
        else
            origin:drop( item );
        end
    end

    local function createLabel()
        local item = dragContext.item
        local label = Translator.getText( item:getID() )
        if item:instanceOf( 'ItemStack' ) and item:getItemCount() > 1 then
            label = string.format( '%s (%d)', label, item:getItemCount() )
        end
        return label
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:draw( lists )
        if not dragContext then
            return
        end

        local tw, th = TexturePacks.getTileDimensions()
        local gx, gy = GridHelper.getMouseGridPosition()

        -- Move background and draw it.
        background:setOrigin( gx, gy )
        background:setColor( 'ui_inventory_drag_bg' )
        background:draw()

        -- Check if the dragged item would fit.
        TexturePacks.setColor( 'ui_inventory_drag_text' )
        for _, list in pairs( lists ) do
            if list:isMouseOver() then
                if not list:doesFit( dragContext.item ) then
                    TexturePacks.setColor( 'ui_inventory_full' )
                    break
                end
            end
        end

        love.graphics.print( createLabel(), (gx+1) * tw, gy * th )
        TexturePacks.resetColor()
    end

    function self:drag( item, origin )
        assert( item and origin, 'Missing parameters.' )
        love.mouse.setVisible( false )
        dragContext = { item = item, origin = origin }
    end

    function self:drop( target )
        love.mouse.setVisible( true )

        if not target then
            returnItemToOrigin( dragContext.item, dragContext.origin )
        else
            local success = target:drop( dragContext.item, dragContext.origin )
            if not success then
                returnItemToOrigin( dragContext.item, dragContext.origin )
            end
        end

        self:clearDragContext()
    end

    function self:hasDragContext()
        return dragContext ~= nil
    end

    function self:getDragContext()
        return dragContext
    end

    function self:clearDragContext()
        dragContext = nil
    end

    function self:getDraggedItem()
        return dragContext.item
    end

    return self
end

return UIInventoryDragboard
