local UIList = require( 'src.ui.elements.UIList' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local VerticalList = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function VerticalList.new( x, y, itemW, itemH )
    local self = UIList.new():addInstance( 'VerticalList' );

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update()
        if not love.mouse.isVisible() then
            return;
        end

        self:unsetCursor()

        local elements = self:getElements();
        for i = 1, #elements do
            elements[i]:update( x, y + (i-1) * itemH, itemW, itemH );
            if elements[i]:hasFocus() then
                self:setCursor( i );
            end
        end
    end

    function self:draw()
        local elements = self:getElements();
        for i = 1, #elements do
            love.graphics.setColor( elements[i]:hasFocus() and COLORS.DB18 or COLORS.DB16 );
            elements[i]:draw( x, y + (i-1) * itemH, itemW, itemH );
            love.graphics.setColor( COLORS.RESET );
        end
    end

    function self:keypressed( _, scancode )
        if scancode == 'up' then
            self:deactivateMouse();
            self:prev();
        elseif scancode == 'down' then
            self:deactivateMouse();
            self:next();
        elseif self:getActiveElement() then
            self:getActiveElement():keypressed( _, scancode );
        end
    end

    function self:mousereleased()
        if love.mouse.isVisible() and self:getActiveElement() then
            self:getActiveElement():mousereleased();
        end
    end

    function self:activateMouse()
        love.mouse.setVisible( true );
    end

    function self:deactivateMouse()
        love.mouse.setVisible( false );

        local elements = self:getElements();
        for i = 1, #elements do
            elements[i]:setFocus( false );
        end
    end

    function self:mousemoved()
        self:activateMouse();
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setPosition( nx, ny )
        x, y = nx, ny;
    end

    return self;
end

return VerticalList;
