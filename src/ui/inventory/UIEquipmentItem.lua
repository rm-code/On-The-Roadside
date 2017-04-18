local Object = require( 'src.Object' );
local Translator = require( 'src.util.Translator' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

local UIEquipmentItem = {};

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
        if highlight then
            TexturePacks.setColor( 'ui_equipment_highlight' )
        elseif self:isMouseOver() then
            TexturePacks.setColor( 'ui_equipment_mouseover' )
        else
            TexturePacks.setColor( 'sys_background' )
        end

        love.graphics.rectangle( 'fill', x, y, width, height );

        if slot:containsItem() then
            TexturePacks.setColor( 'ui_equipment_item' )
        else
            TexturePacks.setColor( 'ui_equipment_empty' )
        end

        love.graphics.print( createLabel(), x, y );
    end

    function self:highlight( nitem )
        highlight = nitem and nitem:isSameType( slot:getItemType(), slot:getSubType() ) or false
    end

    function self:getSlot()
        return slot;
    end

    return self;
end

return UIEquipmentItem;
