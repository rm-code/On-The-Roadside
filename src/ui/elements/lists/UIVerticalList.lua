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
    UIVerticalList.super.addChild( self, child )
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

    for i = 1, #elements do
        elements[i]:setFocus( false )
        if elements[i]:isMouseOver() then
            elements[i]:setFocus( true )
            self.cursor = i
        end
    end
end

function UIVerticalList:draw()
    local elements = self.children
    for i = 1, #elements do
        elements[i]:draw()
    end
end

function UIVerticalList:command( cmd )
    if cmd == 'up' then
        self:prev()
    elseif cmd == 'down' then
        self:next()
    elseif self:getActiveElement() then
        self:getActiveElement():command( cmd )
    end
end

function UIVerticalList:mousecommand( cmd )
    self:getActiveElement():command( cmd )
end

return UIVerticalList
