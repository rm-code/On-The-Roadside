local Object = require( 'src.Object' );
local Translator = require( 'src.util.Translator' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Button = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Button.new( textID, callback )
    local self = Object.new():addInstance( 'Button' );

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local translatedText = Translator.getText( textID );
    local x, y, w, h;
    local focus;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update( nx, ny, nw, nh )
        x, y, w, h = nx, ny, nw, nh;

        local mx, my = love.mouse.getPosition();
        focus = ( mx > x and mx < x + w and my > y and my < y + h );
    end

    function self:draw()
        love.graphics.setColor( focus and COLORS.DB18 or COLORS.DB16 );
        love.graphics.print( translatedText, x, y );
        love.graphics.setColor( 255, 255, 255 );
    end

    function self:activate()
        callback();
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
