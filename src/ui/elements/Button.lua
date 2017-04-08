local Object = require( 'src.Object' );
local Translator = require( 'src.util.Translator' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Button = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Button.new( textID, callback )
    local self = Object.new():addInstance( 'Button' );

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local translatedText = Translator.getText( textID );
    local focus;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update( x, y, w, h )
        local mx, my = love.mouse.getPosition();
        focus = ( mx > x and mx < x + w and my > y and my < y + h );
    end

    function self:draw( x, y, w, _ )
        TexturePacks.setColor( focus and 'ui_button_hot' or 'ui_button' )
        love.graphics.printf( translatedText, x, y, w, 'center' );
        TexturePacks.resetColor()
    end

    function self:activate()
        callback();
    end

    function self:keypressed( _, scancode )
        if scancode == 'return' then
            self:activate();
        end
    end

    function self:mousereleased()
        self:activate();
    end

    -- ------------------------------------------------
    -- Getter
    -- ------------------------------------------------

    function self:hasFocus()
        return focus;
    end

    function self:getText()
        return translatedText
    end

    -- ------------------------------------------------
    -- Setter
    -- ------------------------------------------------

    function self:setFocus( nfocus )
        focus = nfocus;
    end

    return self;
end

return Button;
