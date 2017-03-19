local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIList = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIList.new()
    local self = Object.new():addInstance( 'UIList' );

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local elements = {};
    local cursor = 1;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:addElement( nelement )
        elements[#elements + 1] = nelement;

        -- Set the focus on the first element.
        if #elements == 1 then
            nelement:setFocus( true );
        end
    end

    function self:prev()
        elements[cursor]:setFocus( false );
        cursor = cursor == 1 and #elements or cursor - 1;
        elements[cursor]:setFocus( true );
    end

    function self:next()
        elements[cursor]:setFocus( false );
        cursor = cursor == #elements and 1 or cursor + 1;
        elements[cursor]:setFocus( true );
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getElements()
        return elements;
    end

    function self:getActiveElement()
        return elements[cursor];
    end

    function self:getCursor()
        return cursor;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setCursor( ncursor )
        cursor = ncursor;
    end

    return self;
end

return UIList;
