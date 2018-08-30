---
-- @module UIList
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local Util = require( 'src.util.Util' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIList = UIElement:subclass( 'UIList' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function scrollItem( current, children, cursor, direction )
    if current then
        current:setFocus( false )
        cursor = Util.wrap( 1, cursor + direction, #children )
    else
        cursor = 1
    end
    children[cursor]:setFocus( true )

    return cursor
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIList:initialize( ox, oy, rx, ry, w, h )
  UIElement.initialize( self, ox, oy, rx, ry, w, h )
  self.cursor = 1
end

function UIList:prev()
    self.cursor = scrollItem( self:getActiveElement(), self.children, self.cursor, -1 )
end

function UIList:next()
    self.cursor = scrollItem( self:getActiveElement(), self.children, self.cursor, 1 )
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function UIList:getActiveElement()
    return self.children[self.cursor]
end

function UIList:getCursor()
    return self.cursor
end

function UIList:getElementCount()
    return #self.children
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function UIList:setCursor( ncursor )
    self.cursor = ncursor
end

function UIList:setFocus( focus )
    UIList.super.setFocus( self, focus )
    self.children[self.cursor]:setFocus( focus )
end

return UIList
