local Object = require( 'src.Object' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

local SelectField = {};

function SelectField.new( font, label, listOfValues, callback, default )
    local self = Object.new():addInstance( 'SelectField' );

    local current = default or 1;
    local focus = false;

    function self:draw( x, y, w, _ )
        TexturePacks.setColor( focus and 'ui_select_field_hot' or 'ui_select_field' )
        love.graphics.print( label, x, y );
        love.graphics.print( listOfValues[current].displayTextID, x + w - font:measureWidth( listOfValues[current].displayTextID ), y )
        TexturePacks.resetColor()
    end

    function self:update( x, y, w, h )
        local mx, my = love.mouse.getPosition();
        focus = ( mx > x and mx < x + w and my > y and my < y + h );
    end

    function self:next()
        current = current == #listOfValues and 1 or current + 1;
        callback( listOfValues[current].value );
    end

    function self:prev()
        current = current == 1 and #listOfValues or current - 1;
        callback( listOfValues[current].value );
    end

    function self:keypressed( _, scancode )
        if scancode == 'left' then
            self:prev();
        elseif scancode == 'right' then
            self:next();
        end
    end

    function self:mousereleased()
        self:next();
    end

    function self:hasFocus()
        return focus;
    end

    function self:setFocus( nfocus )
        focus = nfocus;
    end

    return self;
end

return SelectField;
