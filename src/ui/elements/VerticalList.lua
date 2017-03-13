local Object = require( 'src.Object' );

local VerticalList = {};

local COLORS = require( 'src.constants.Colors' );

function VerticalList.new( x, y, itemW, itemH )
    local self = Object.new():addInstance( 'VerticalList' );

    local elements = {};
    local current = 1;

    function self:addElement( nelement )
        elements[#elements + 1] = nelement;
    end

    function self:draw()
        for i = 1, #elements do
            love.graphics.setColor( elements[i]:hasFocus() and COLORS.DB18 or COLORS.DB16 );
            elements[i]:draw( x, y + (i-1) * itemH, itemW, itemH );
            love.graphics.setColor( 255, 255, 255 );
        end
    end

    function self:update()
        if not love.mouse.isVisible() then
            return;
        end

        for i = 1, #elements do
            elements[i]:update( x, y + (i-1) * itemH, itemW, itemH );
            if elements[i]:hasFocus() then
                current = i;
            end
        end
    end

    function self:keypressed( _, scancode )
        if scancode == 'right' then
            elements[current]:next();
        elseif scancode == 'left' then
            elements[current]:prev();
        end
        if scancode == 'up' then
            self:deactivateMouse();
            elements[current]:setFocus( false );
            current = current == 1 and #elements or current - 1;
            elements[current]:setFocus( true );
        elseif scancode == 'down' then
            self:deactivateMouse();
            elements[current]:setFocus( false );
            current = current == #elements and 1 or current + 1;
            elements[current]:setFocus( true );
        end
    end

    function self:mousereleased()
        elements[current]:next();
    end

    function self:activateMouse()
        love.mouse.setVisible( true );
    end

    function self:deactivateMouse()
        love.mouse.setVisible( false );

        for i = 1, #elements do
            elements[i]:setFocus( false );
        end
    end

    function self:mousemoved()
        self:activateMouse();
    end

    function self:setPosition( nx, ny )
        x, y = nx, ny;
    end

    return self;
end

return VerticalList;
