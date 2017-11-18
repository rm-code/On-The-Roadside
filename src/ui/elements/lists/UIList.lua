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
        self.cursor = self.cursor <= 1 and #self.children or self.cursor - 1
    else
        self.cursor = 1
    end
    self.children[self.cursor]:setFocus( true )
end

function UIList:next()
    if self.children[self.cursor] then
        self.children[self.cursor]:setFocus( false )
        self.cursor = self.cursor >= #self.children and 1 or self.cursor + 1
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

return UIList
