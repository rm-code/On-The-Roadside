local Object = require( 'src.Object' );
local Translator = require( 'src.util.Translator' );

local UIEquipmentItem = {};

local COLORS = require( 'src.constants.Colors' );
local WIDTH  = 150;
local HEIGHT =  30;

---
-- This class actually holds an EquipmentSlot object instead of an item.
--
function UIEquipmentItem.new( id, x, y, slot )
    local self = Object.new():addInstance( 'UIEquipmentItem' );

    local mouseOver = false;

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
        mouseOver = ( mx > x and mx < x + WIDTH and my > y and my < y + HEIGHT );
    end

    function self:isMouseOver()
        return mouseOver;
    end

    function self:draw()
        if self:isMouseOver() then
            love.graphics.setColor( COLORS.DB15 );
        else
            love.graphics.setColor( COLORS.DB00 );
        end

        love.graphics.rectangle( 'fill', x, y, WIDTH, HEIGHT );

        love.graphics.setColor( COLORS.DB23 );
        love.graphics.rectangle( 'line', x, y, WIDTH, HEIGHT );

        love.graphics.setScissor( x, y, WIDTH, HEIGHT );

        if not slot:containsItem() then
            love.graphics.setColor( COLORS.DB23 );
        else
            love.graphics.setColor( COLORS.DB21 );
        end
        love.graphics.printf( createLabel(), x, y + 5, WIDTH, 'center' );
        love.graphics.setScissor();
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
