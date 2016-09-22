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

local PADDING = 15;
local HEADER_HEIGHT = 30;
local WIDTH = 150;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIInventoryList.new( x, y, id, inventory )
    local self = Object.new():addInstance( 'UIInventoryList' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local list;
    local weightText;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function regenerate()
        list = {};
        for i, item in ipairs( inventory:getItems() ) do
            list[#list + 1] = UIInventoryItem.new( x, HEADER_HEIGHT + ( y + PADDING ) * i, item );
        end
        weightText = string.format( '%.1f/%.1f', inventory:getWeight(), inventory:getWeightLimit() );
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
        love.graphics.printf( Translator.getText( id ), x + 5, y + 5, WIDTH - 10, 'left' );
        love.graphics.printf( weightText, x + 5, y + 5, WIDTH - 10, 'right' );
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

    return self;
end

return UIInventoryList;
