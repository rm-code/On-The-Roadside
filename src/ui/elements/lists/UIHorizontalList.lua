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

local UIHorizontalList = UIList:subclass( 'UIHorizontalList' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIHorizontalList:update()
    local elements = self.children
    local itemWidth = math.floor( self.w / #elements )

    for i = 1, #elements do
        -- Update the elements width based on the list#s width.
        elements[i]:setWidth( itemWidth )

        -- Render list items at their correct offset and reset focus.
        elements[i]:setRelativePosition( (i-1) * itemWidth, 0 )
    end

    if not love.mouse.isVisible() then
        return
    end

    for i = 1, #elements do
        elements[i]:setFocus( false )
        if elements[i]:isMouseOver() then
            elements[i]:setFocus( true )
            self.cursor = i
        end
    end
end

function UIHorizontalList:draw()
    local elements = self.children
    for i = 1, #elements do
        elements[i]:draw()
    end
end

function UIHorizontalList:command( cmd )
    if cmd == 'right' then
        self:next()
    elseif cmd == 'left' then
        self:prev()
    elseif self:getActiveElement() then
        self:getActiveElement():command( cmd )
    end
end

function UIHorizontalList:mousecommand( cmd )
    self:getActiveElement():command( cmd )
end

return UIHorizontalList
