local Object = require( 'src.Object' );
local UIInventoryItem = require( 'src.ui.inventory.UIInventoryItem' );
local Translator = require( 'src.util.Translator' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIInventoryList = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIInventoryList.new( x, y, width, id, inventory )
    local self = Object.new():addInstance( 'UIInventoryList' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local list;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function regenerate()
        list = {};
        for i, item in ipairs( inventory:getItems() ) do
            list[#list + 1] = UIInventoryItem.new( x, y + i * TILE_SIZE, width, TILE_SIZE, item );
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
        for _, uiItem in ipairs( list ) do
            uiItem:isMouseOver();
        end
        return ( mx > x and mx < x + width );
    end

    function self:drop( item )
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() then
                local success = inventory:insertItem( item, uiItem:getItem() );
                if success then
                    regenerate();
                    return true;
                end
            end
        end

        local success = inventory:addItem( item );
        if success then
            regenerate();
            return true;
        end
        return false;
    end

    function self:drag( rmb, fullstack )
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() then
                local item = uiItem:drag( rmb, fullstack );
                inventory:removeItem( item );
                regenerate();
                return item;
            end
        end
    end

    function self:getLabel()
        return Translator.getText( id );
    end

    return self;
end

return UIInventoryList;
