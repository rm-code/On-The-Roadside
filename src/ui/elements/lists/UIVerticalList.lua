---
-- @module UIVerticalList
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIList = require( 'src.ui.elements.lists.UIList' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIVerticalList = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIVerticalList.new( px, py, x, y, w, h )
    local self = UIList.new( px, py, x, y, w, h ):addInstance( 'UIVerticalList' )

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update()
        if not love.mouse.isVisible() then
            return
        end

        -- Check if mouse is over any elements.
        local elements = self.children
        for i = 1, #elements do
            elements[i]:setFocus( false )
            if elements[i]:isMouseOver() then
                self:setCursor( i )
            end
        end

        -- Set the focus to the element at the current cursor position.
        local cursor = self:getCursor()
        elements[cursor]:setFocus( true )
    end

    function self:draw()
        local elements = self.children
        for i = 1, #elements do
            elements[i]:draw()
        end
    end

    function self:command( cmd )
        if cmd == 'up' then
            self:deactivateMouse()
            self:prev()
        elseif cmd == 'down' then
            self:deactivateMouse()
            self:next()
        elseif self:getActiveElement() then
            self:getActiveElement():command( cmd )
        end
    end

    return self
end

return UIVerticalList
