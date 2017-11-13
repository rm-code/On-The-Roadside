---
-- @module UIHorizontalList
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIList = require( 'src.ui.elements.lists.UIList' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIHorizontalList = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIHorizontalList.new( px, py, x, y, w, h )
    local self = UIList.new( px, py, x, y, w, h ):addInstance( 'HorizontalList' )

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update()
        local elements = self.children
        local itemWidth = math.floor( self.w / #elements )

        for i = 1, #elements do
            -- Render list items at their correct offset and reset focus.
            elements[i]:setRelativePosition( (i-1) * itemWidth, 0 )
            elements[i]:setFocus( false )

            -- Check for mouse focus if the mouse cursor is active.
            if love.mouse.isVisible() and elements[i]:isMouseOver() then
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
        if cmd == 'right' then
            self:deactivateMouse()
            self:next()
        elseif cmd == 'left' then
            self:deactivateMouse()
            self:prev()
        elseif self:getActiveElement() then
            self:getActiveElement():command( cmd )
        end
    end

    return self
end

return UIHorizontalList
