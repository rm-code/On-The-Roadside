local Object = require( 'src.Object' );
local ImageFont = require( 'src.ui.ImageFont' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ButtonList = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local BUTTON_PADDING = 8;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function ButtonList.new()
    local self = Object.new():addInstance( 'ButtonList' );

    local buttons = {};
    local x, y;
    local cursor = 1;

    love.mouse.setVisible( true );

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update()
        if not love.mouse.isVisible() then
            return;
        end

        local w = 0;
        for i = 1, #buttons do
            if i > 1 then
                w = w + ImageFont.measureWidth( buttons[i-1]:getText() );
                w = w + BUTTON_PADDING * ImageFont.getGlyphWidth();
            end
            buttons[i]:update( x + w, y, ImageFont.measureWidth( buttons[i]:getText() ), ImageFont.getGlyphHeight() );

            if buttons[i]:hasFocus() then
                cursor = i;
            end
        end
    end

    function self:draw()
        for i = 1, #buttons do
            buttons[i]:draw();
        end
    end

    function self:addButton( nbutton )
        buttons[#buttons + 1] = nbutton;
    end

    function self:keypressed( _, scancode )
        if scancode == 'right' then
            self:deactivateMouse();
            buttons[cursor]:setFocus( false );
            cursor = cursor == #buttons and 1 or cursor + 1;
            buttons[cursor]:setFocus( true );
        elseif scancode == 'left' then
            self:deactivateMouse();
            buttons[cursor]:setFocus( false );
            cursor = cursor == 1 and #buttons or cursor - 1;
            buttons[cursor]:setFocus( true );
        elseif scancode == 'return' then
            self:deactivateMouse();
            buttons[cursor]:activate();
        end
    end

    function self:mousereleased()
        buttons[cursor]:activate();
    end

    function self:activateMouse()
        love.mouse.setVisible( true );
    end

    function self:deactivateMouse()
        love.mouse.setVisible( false );

        for i = 1, #buttons do
            buttons[i]:setFocus( false );
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getWidth()
        local w = 0;
        for i = 1, #buttons do
            if i > 1 then
                w = w + ImageFont.measureWidth( buttons[i-1]:getText() );
                w = w + BUTTON_PADDING * 8;
            end
        end
        -- Count the last string.
        w = w + ImageFont.measureWidth( buttons[#buttons]:getText() );
        return w;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setPosition( nx, ny )
        x, y = nx, ny;
    end

    return self;
end

return ButtonList;
