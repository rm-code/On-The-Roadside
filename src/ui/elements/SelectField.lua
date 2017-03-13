local Object = require( 'src.Object' );
local ImageFont = require( 'src.ui.ImageFont' );

local SelectField = {};

function SelectField.new( label, listOfValues, callback )
    local self = Object.new():addInstance( 'SelectField' );

    local current = 1;
    local focus = false;

    function self:draw( x, y, w, _ )
        love.graphics.print( label, x, y );
        love.graphics.print( listOfValues[current].displayTextID, x + w - ImageFont.measureWidth( listOfValues[current].displayTextID ), y );
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
