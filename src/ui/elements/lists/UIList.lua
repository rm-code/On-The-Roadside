---
-- @module UIList
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIList = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIList.new( px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UIList' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local cursor = 1

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:prev()
        if self.children[cursor] then
            self.children[cursor]:setFocus( false )
            cursor = cursor <= 1 and #self.children or cursor - 1
        else
            cursor = 1
        end
        self.children[cursor]:setFocus( true )
    end

    function self:next()
        if self.children[cursor] then
            self.children[cursor]:setFocus( false )
            cursor = cursor >= #self.children and 1 or cursor + 1
        else
            cursor = 1
        end
        self.children[cursor]:setFocus( true )
    end

    function self:mousereleased( mx, my, button, isTouch )
        if love.mouse.isVisible() and self:getActiveElement() then
            self:getActiveElement():mousereleased( mx, my, button, isTouch )
        end
    end

    function self:activateMouse()
        love.mouse.setVisible( true )
    end

    function self:deactivateMouse()
        love.mouse.setVisible( false )
    end

    function self:mousemoved()
        self:activateMouse()
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getActiveElement()
        return self.children[cursor]
    end

    function self:getCursor()
        return cursor
    end

    function self:getElementCount()
        return #self.children
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setCursor( ncursor )
        cursor = ncursor
    end

    function self:unsetCursor()
        cursor = 0
    end

    return self
end

return UIList
