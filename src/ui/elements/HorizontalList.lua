local UIList = require( 'src.ui.elements.UIList' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local HorizontalList = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function HorizontalList.new( x, y, itemW, itemH )
    local self = UIList.new():addInstance( 'HorizontalList' );

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update()
        if not love.mouse.isVisible() then
            return;
        end

        local elements = self:getElements();
        local w = #elements * itemW;
        local ox = x - w * 0.5;

        for i = 1, #elements do
            elements[i]:update( ox + (i-1) * itemW, y, itemW, itemH );

            if elements[i]:hasFocus() then
                self:setCursor( i );
            end
        end
    end

    function self:draw()
        local elements = self:getElements();
        local w = #elements * itemW;
        local ox = x - w * 0.5;

        for i = 1, #elements do
            elements[i]:draw( ox + (i-1) * itemW, y, itemW, itemH );
        end
    end

    function self:keypressed( key, scancode )
        if scancode == 'right' then
            self:deactivateMouse();
            self:next();
        elseif scancode == 'left' then
            self:deactivateMouse();
            self:prev();
        else
            self:getActiveElement():keypressed( key, scancode );
        end
    end

    function self:mousereleased()
        self:getActiveElement():mousereleased();
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

return HorizontalList;
