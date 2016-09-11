local Object = require( 'src.Object' );
local UIInventoryItem = require( 'src.ui.inventory.UIInventoryItem' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIEquipmentList = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ItemTypes');
local PADDING = 15;
local HEADER_HEIGHT = 30;
local WIDTH = 150;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIEquipmentList.new( x, y, name, equipment )
    local self = Object.new():addInstance( 'UIEquipmentList' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local list;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function regenerate()
        list = {
            UIInventoryItem.new( x, HEADER_HEIGHT + ( y + PADDING ) * 1, equipment:getWeapon() );
            UIInventoryItem.new( x, HEADER_HEIGHT + ( y + PADDING ) * 2, equipment:getBackpack() );
            UIInventoryItem.new( x, HEADER_HEIGHT + ( y + PADDING ) * 3, equipment:getClothingItem( ITEM_TYPES.HEADGEAR ));
            UIInventoryItem.new( x, HEADER_HEIGHT + ( y + PADDING ) * 4, equipment:getClothingItem( ITEM_TYPES.GLOVES ));
            UIInventoryItem.new( x, HEADER_HEIGHT + ( y + PADDING ) * 5, equipment:getClothingItem( ITEM_TYPES.JACKET ));
            UIInventoryItem.new( x, HEADER_HEIGHT + ( y + PADDING ) * 6, equipment:getClothingItem( ITEM_TYPES.SHIRT ));
            UIInventoryItem.new( x, HEADER_HEIGHT + ( y + PADDING ) * 7, equipment:getClothingItem( ITEM_TYPES.TROUSERS ));
            UIInventoryItem.new( x, HEADER_HEIGHT + ( y + PADDING ) * 8, equipment:getClothingItem( ITEM_TYPES.FOOTWEAR ));
        };
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
        love.graphics.printf( name, x, y + 5, WIDTH, 'center' );
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
        if equipment:containsItem( item ) then
            local tmp = equipment:removeItem( item );
            equipment:addItem( item );
            origin:drop( tmp );
        end
        equipment:addItem( item );
        regenerate();
    end

    ---
    -- Checks if the mouse is over one of the UIItems in this list. If it is,
    -- the contained Item will be removed and returned.
    -- @return (Item) The item contained in the UIItem.
    --
    function self:drag()
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() then
                local item = uiItem:drag();

                -- Ignore empty slots.
                if not item then
                    return;
                end

                equipment:removeItem( item );
                regenerate();
                return item;
            end
        end
    end

    return self;
end

return UIEquipmentList;
