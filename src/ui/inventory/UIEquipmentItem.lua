local UIInventoryItem = require( 'src.ui.inventory.UIInventoryItem' );
local Translator = require( 'src.util.Translator' );

local UIEquipmentItem = {};

local COLORS = require( 'src.constants.Colors' );
local WIDTH  = 150;
local HEIGHT =  30;

function UIEquipmentItem.new( id, x, y, item )
    local self = UIInventoryItem.new( x, y, item ):addInstance( 'UIEquipmentItem' );

    local function createLabel()
        if not self:hasItem() then
            local text = Translator.getText( id );
            return string.upper( text );
        else
            local text = Translator.getText( self:getItem():getID() )
            if self:getItem():instanceOf( 'ItemStack' ) and self:getItem():getItemCount() > 1 then
                text = string.format( '%s (%d)', text, self:getItem():getItemCount() );
            end
            return text;
        end
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

        if not self:hasItem() then
            love.graphics.setColor( COLORS.DB23 );
        else
            love.graphics.setColor( COLORS.DB21 );
        end
        love.graphics.printf( createLabel(), x, y + 5, WIDTH, 'center' );
        love.graphics.setScissor();
    end

    return self;
end

return UIEquipmentItem;
