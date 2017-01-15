local Object = require( 'src.Object' );
local UIEquipmentItem = require( 'src.ui.inventory.UIEquipmentItem' );
local Translator = require( 'src.util.Translator' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIEquipmentList = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local PADDING = 15;
local HEADER_HEIGHT = 30;
local WIDTH = 150;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIEquipmentList.new( x, y, id, character )
    local self = Object.new():addInstance( 'UIEquipmentList' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local equipment = character:getEquipment();
    local list;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function regenerate()
        list = {};

        -- TODO replace with custom EquipmentItem class
        for _, slot in pairs( equipment:getSlots() ) do
            local uiItem = UIEquipmentItem.new( slot:getID(), x, HEADER_HEIGHT + ( y + PADDING ) * slot:getSortOrder(), slot );
            table.insert( list, slot:getSortOrder(), uiItem );
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        regenerate();
    end

    function self:draw()
        love.graphics.setColor( 0, 0, 0 );
        love.graphics.rectangle( 'fill', x, y, WIDTH, HEADER_HEIGHT );
        love.graphics.setColor( 200, 200, 200 );
        love.graphics.rectangle( 'line', x, y, WIDTH, HEADER_HEIGHT );
        love.graphics.setColor( 255, 255, 255 );
        love.graphics.setScissor( x, y, WIDTH, HEADER_HEIGHT );
        love.graphics.printf( Translator.getText( id ), x, y + 5, WIDTH, 'center' );
        love.graphics.setScissor();

        for _, slot in ipairs( list ) do
            slot:draw();
        end
    end

    function self:update( dt )
        for _, slot in ipairs( list ) do
            slot:update( dt );
        end
    end

    function self:isMouseOver()
        local mx = love.mouse.getX();
        return ( mx > x and mx < x + WIDTH );
    end

    ---
    -- Drops an item onto this list. If the slot the item belongs to already
    -- contains an item, that item will be swapped to the inventory the new item
    -- is coming from.
    -- @param item   (Item)            The new item to place in a equipment slot.
    -- @param origin (UIInventoryList) The inventory list the item is coming from.
    --
    function self:drop( item, origin )
        local success = false;
        if item:instanceOf( 'ItemStack' ) or not item:isEquippable() then
            return success;
        end

        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() and uiItem:getSlot():getItemType() == item:getItemType() then
                if uiItem:getSlot():containsItem() then
                    local tmp = uiItem:getSlot():getAndRemoveItem();
                    success = uiItem:getSlot():addItem( item );
                    origin:drop( tmp );
                else
                    success = uiItem:getSlot():addItem( item );
                end
            end
        end

        regenerate();
        return success;
    end

    ---
    -- Checks if the mouse is over one of the UIItems in this list. If it is,
    -- the contained Item will be removed and returned.
    -- @return (Item) The item contained in the UIItem.
    --
    function self:drag()
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() and uiItem:getSlot():containsItem() then
                local item = uiItem:drag();
                regenerate();
                return item;
            end
        end
    end

    return self;
end

return UIEquipmentList;
