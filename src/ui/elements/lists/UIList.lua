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
-- Public Methods
-- ------------------------------------------------

function UIList:initialize( ox, oy, rx, ry, w, h )
  UIElement.initialize( self, ox, oy, rx, ry, w, h )
  self.cursor = 1
end

function UIList:prev()
    if self.children[self.cursor] then
        self.children[self.cursor]:setFocus( false )
        self.cursor = Util.wrap( 1, self.cursor - 1, #self.children )
    else
        self.cursor = 1
    end
    self.children[self.cursor]:setFocus( true )
end

function UIList:next()
    if self.children[self.cursor] then
        self.children[self.cursor]:setFocus( false )
        self.cursor = Util.wrap( 1, self.cursor + 1, #self.children )
    else
        self.cursor = 1
    end
    self.children[self.cursor]:setFocus( true )
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
