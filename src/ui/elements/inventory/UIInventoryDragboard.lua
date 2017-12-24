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
local Equipment = require( 'src.characters.body.Equipment' )
local ItemStack = require( 'src.inventory.ItemStack' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIInventoryDragboard = Observable:subclass( 'UIInventoryDragboard' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_WIDTH = 20

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function returnItemToOrigin( item, origin, slot )
    if origin:isInstanceOf( Equipment ) then
        origin:addItem( slot, item )
    else
        origin:drop( item );
    end
end

local function createLabel( item )
    local label = Translator.getText( item:getID() )
    if item:isInstanceOf( ItemStack ) and item:getItemCount() > 1 then
        label = string.format( '%s (%d)', label, item:getItemCount() )
    end
    return label
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIInventoryDragboard:initialize()
    Observable.initialize( self )

    self.background = UIBackground( 0, 0, 0, 0, ITEM_WIDTH, 1 )
end

function UIInventoryDragboard:draw( lists )
    if not self.dragContext then
        return
    end

    local tw, th = TexturePacks.getTileDimensions()
    local gx, gy = GridHelper.getMouseGridPosition()

    -- Move background and draw it.
    self.background:setOrigin( gx, gy )
    self.background:setColor( 'ui_inventory_drag_bg' )
    self.background:draw()

    -- Check if the dragged item would fit.
    TexturePacks.setColor( 'ui_inventory_drag_text' )
    for _, list in pairs( lists ) do
        if list:isMouseOver() then
            if not list:doesFit( self.dragContext.item ) then
                TexturePacks.setColor( 'ui_inventory_full' )
                break
            end
        end
    end

    love.graphics.print( createLabel( self.dragContext.item ), (gx+1) * tw, gy * th )
    TexturePacks.resetColor()
end

function UIInventoryDragboard:drag( item, origin, slot )
    love.mouse.setVisible( false )
    self.dragContext = { item = item, origin = origin, slot = slot }
end

function UIInventoryDragboard:drop( target )
    love.mouse.setVisible( true )

    if not target then
        returnItemToOrigin( self.dragContext.item, self.dragContext.origin, self.dragContext.slot )
    else
        local success = target:drop( self.dragContext.item, self.dragContext.origin )
        if not success then
            returnItemToOrigin( self.dragContext.item, self.dragContext.origin, self.dragContext.slot )
        end
    end

    self:clearDragContext()
end

function UIInventoryDragboard:hasDragContext()
    return self.dragContext ~= nil
end

function UIInventoryDragboard:getDragContext()
    return self.dragContext
end

function UIInventoryDragboard:clearDragContext()
    self.dragContext = nil
end

function UIInventoryDragboard:getDraggedItem()
    return self.dragContext.item
end

return UIInventoryDragboard
