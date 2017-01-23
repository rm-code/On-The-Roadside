local Object = require( 'src.Object' );
local Translator = require( 'src.util.Translator' );

local UIInventoryItem = {};

local COLORS = require( 'src.constants.Colors' );

function UIInventoryItem.new( x, y, width, height, item )
    local self = Object.new():addInstance( 'UIInventoryItem' );

    local mouseOver = false;

    local function createLabel()
        if not item then
            return Translator.getText( 'inventory_empty_slot' );
        else
            local text = Translator.getText( item:getID() )
            if item:instanceOf( 'ItemStack' ) and item:getItemCount() > 1 then
                text = string.format( '%s (%d)', text, item:getItemCount() );
            end
            return text;
        end
    end

    function self:draw()
        if mouseOver then
            love.graphics.setColor( COLORS.DB15 );
        else
            love.graphics.setColor( COLORS.DB00 );
        end
        love.graphics.rectangle( 'fill', x, y, width, height );

        love.graphics.setColor( COLORS.DB20 );
        love.graphics.print( createLabel(), x, y );
    end

    function self:update()
        local mx, my = love.mouse.getPosition();
        mouseOver = ( mx > x and mx < x + width and my > y and my < y + height );
    end

    function self:isMouseOver()
        return mouseOver;
    end

    function self:getItem()
        return item;
    end

    function self:hasItem()
        return item ~= nil;
    end

    function self:drag( rmb, fullstack )
        if item:instanceOf( 'ItemStack' ) and rmb then
            if item:getItemCount() == 1 then
                return item;
            else
                return item:split();
            end
        elseif item:instanceOf( 'ItemStack' ) and not fullstack then
            return item:getItem();
        end
        return item;
    end

    return self;
end

return UIInventoryItem;
