local Object = require( 'src.Object' );
local Translator = require( 'src.util.Translator' );

local UIEquipmentItem = {};

local COLORS = require( 'src.constants.Colors' );

---
-- This class actually holds an EquipmentSlot object instead of an item.
--
function UIEquipmentItem.new( id, x, y, width, height, slot )
    local self = Object.new():addInstance( 'UIEquipmentItem' );

    local mouseOver = false;
    local highlight = false;

    local function createLabel()
        if not slot:containsItem() then
            local text = Translator.getText( id );
            return string.upper( text );
        else
            return Translator.getText( slot:getItem():getID() );
        end
    end

    function self:update()
        local mx, my = love.mouse.getPosition();
        mouseOver = ( mx > x and mx < x + width and my > y and my < y + height );
    end

    function self:isMouseOver()
        return mouseOver;
    end

    function self:draw()
        if self:isMouseOver() then
            love.graphics.setColor( COLORS.DB15 );
        elseif highlight then
            love.graphics.setColor( COLORS.DB10 );
        else
            love.graphics.setColor( COLORS.DB00 );
        end
        love.graphics.rectangle( 'fill', x, y, width, height );

        if not slot:containsItem() then
            love.graphics.setColor( COLORS.DB23 );
        else
            love.graphics.setColor( COLORS.DB20 );
        end

        love.graphics.print( createLabel(), x, y );
    end

    function self:highlight( nitem )
        if nitem then
            highlight = nitem:getItemType() == slot:getItemType();
            return;
        end
        highlight = false;
    end

    function self:drag()
        return slot:getAndRemoveItem();
    end

    function self:getSlot()
        return slot;
    end

    return self;
end

return UIEquipmentItem;
