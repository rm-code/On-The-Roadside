local Object = require( 'src.Object' );
local UIEquipmentItem = require( 'src.ui.inventory.UIEquipmentItem' );
local Translator = require( 'src.util.Translator' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIEquipmentList = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIEquipmentList.new( x, y, width, id, character )
    local self = Object.new():addInstance( 'UIEquipmentList' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local equipment = character:getEquipment();
    local list;
    local tw, th = TexturePacks.getTileDimensions()

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function regenerate()
        list = {};

        for _, slot in pairs( equipment:getSlots() ) do
            local uiItem = UIEquipmentItem.new( slot:getID(), x, y + slot:getSortOrder() * tw, width, th, slot )
            list[slot:getSortOrder()] = uiItem;
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        regenerate();
    end

    function self:draw()
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
        return ( mx > x and mx < x + width );
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
            local slot = uiItem:getSlot();
            if uiItem:isMouseOver() and item:isSameType( slot:getItemType(), slot:getSubType() ) then
                if slot:containsItem() then
                    local tmp = equipment:removeItem( slot );
                    success = equipment:addItem( slot, item );
                    origin:drop( tmp );
                else
                    success = equipment:addItem( slot, item );
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
            if uiItem:isMouseOver() and uiItem:getSlot():containsItem() and not uiItem:getSlot():getItem():isPermanent() then
                local item = equipment:removeItem( uiItem:getSlot() );

                -- TODO warn player
                if item:instanceOf( 'Container' ) then
                    character:getInventory():dropItems( character:getTile() );
                end

                regenerate();
                return item, uiItem:getSlot();
            end
        end
    end

    function self:highlightSlot( nitem )
        for _, uiItem in ipairs( list ) do
            uiItem:highlight( nitem );
        end
    end

    function self:getItemBelowCursor()
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() then
                return uiItem:getSlot():getItem();
            end
        end
    end

    function self:getLabel()
        return Translator.getText( id );
    end

    function self:doesFit()
        return true;
    end

    return self;
end

return UIEquipmentList;
