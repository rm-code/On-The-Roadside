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

local UIVerticalList = UIList:subclass( 'UIVerticalList' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new instance of UIVerticalList.
--
function UIVerticalList:initialize( ox, oy, rx, ry, w, h )
    UIList.initialize( self, ox, oy, rx, ry, w, h )
end

----
-- Adds a new child to the vertical list and updates the height information
-- accordingly.
-- @Override
-- @tparam UIElement child The UIElement to add to the list.
--
function UIVerticalList:addChild( child )
    self.h = self.h + child.h
    UIList.super.addChild( self, child )
end

function UIVerticalList:update()
    local elements = self.children
    local height = 0

    for i = 1, #elements do
        elements[i]:setRelativePosition( 0, self.ry + height )
        height = height + elements[i]:getHeight()
    end

    self.h = height

    if not love.mouse.isVisible() then
        return
    end

    -- Check if mouse is over any elements.
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

function UIVerticalList:draw()
    local elements = self.children
    for i = 1, #elements do
        elements[i]:draw()
    end
end

function UIVerticalList:command( cmd )
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

return UIVerticalList
