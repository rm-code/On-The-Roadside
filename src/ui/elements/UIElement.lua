---
-- The parent class for all UI elements.
-- @module UIElement
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIElement = Class( 'UIElement' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new UIElement.
--
-- All of the coordinates should be grid aligned and independent from actual
-- pixel represenations.
--
-- @tparam number ox The origin along the x-axis.
-- @tparam number oy The origin along the y-axis.
-- @tparam number rx The relative coordinate along the x-axis.
-- @tparam number ry The relative coordinate along the y-axis.
-- @tparam number w  The width of this element.
-- @tparam number h  The height of this element.
--
function UIElement:initialize( ox, oy, rx, ry, w, h )
    self.children = {}

    self.focus = false

    -- Origin (parent coordinates).
    self.ox = ox
    self.oy = oy

    -- Coordinates relative to the origin.
    self.rx = rx
    self.ry = ry

    -- Absolute coordinates.
    self.ax = ox+rx
    self.ay = oy+ry

    -- Dimensions.
    self.w  = w
    self.h  = h
end

---
-- Dummy function.
--
function UIElement:draw()
    return
end

---
-- Dummy function.
--
function UIElement:update()
    return
end

function UIElement:command()
    return
end

---
-- Adds a new UIElement to the list of children.
--
-- NOTE: If you use custom indexes you should make sure that you don't break the
-- sequence (1, 2, 3, ... n). Trying to iterate over an array with can have
-- unforeseen consequences in Lua.
--
-- @tparam UIElement child The UIElement to add as a child.
-- @tparam number    index A custom index to use (optional).
--
function UIElement:addChild( child, index )
    if not child:isInstanceOf( UIElement ) then
        error( 'Children of a UIElement must be derived from the UIElement class themselves.' )
    end

    -- Create a new index or use the one provided as a parameter.
    index = index or #self.children + 1

    self.children[index] = child
end

---
-- Sets the origin for this UIElement and updates the absolute position
-- accordingly.
-- @tparam number nx The new origin along the x-axis.
-- @tparam number ny The new origin along the y-axis.
--
function UIElement:setOrigin( nx, ny )
    self.ox = nx
    self.oy = ny
    self.ax = self.ox + self.rx
    self.ay = self.oy + self.ry

    for i = 1, #self.children do
        self.children[i]:setOrigin( self.ax, self.ay )
    end
end

---
-- Sets the relative position for this UIElement and updates its absolute
-- position accordingly.
-- @tparam number rx The relative coordinate along the x-axis.
-- @tparam number ry The relative coordinate along the y-axis.
--
function UIElement:setRelativePosition( nx, ny )
    self.rx = nx
    self.ry = ny
    self.ax = self.ox + self.rx
    self.ay = self.oy + self.ry

    for i = 1, #self.children do
        self.children[i]:setOrigin( self.ax, self.ay )
    end
end

---
-- Checks wether or not the mouse cursor is over this element.
-- @treturn boolean True if the mouse is within this element's bounds.
--
function UIElement:isMouseOver()
    local gx, gy = GridHelper.getMouseGridPosition()
    return  gx >= self.ax
        and gx <  self.ax + self.w
        and gy >= self.ay
        and gy <  self.ay + self.h
end

---
-- Updates this UIElement's width.
-- @tparam number The new width.
--
function UIElement:setWidth( width )
    self.w = width
end

---
-- Returns the UIElement's width.
-- @treturn number The width.
--
function UIElement:getWidth()
    return self.w
end

---
-- Updates this UIElement's height.
-- @tparam number The new height.
--
function UIElement:setHeight( height )
    self.h = height
end

---
-- Returns the UIElement's height.
-- @treturn number The height.
--
function UIElement:getHeight()
    return self.h
end

---
-- Sets the focus for this UIElement. Focus should be used as a way to
-- mark UIElements which should receive keypresses and are the "current"
-- point of focus for the player.
-- @tparam boolean nfocus The new focus value.
--
function UIElement:setFocus( nfocus )
    self.focus = nfocus
end

---
-- Checks wether this UIElement has focus or not.
-- @treturn boolean True if the element has focus.
--
function UIElement:hasFocus()
    return self.focus
end

---
-- Draws the bounding boxes of the UIElement and all of its children as white
-- rectangles for debugging purposes.
-- @tparam number tw The game's tile width.
-- @tparam number th The game's tile height.
--
function UIElement:drawBoundingBox( tw, th )
    love.graphics.rectangle( 'line', self.ax * tw, self.ay * th, self.w * tw, self.h * th )

    for i = 1, #self.children do
        self.children[i]:drawBoundingBox( tw, tw )
    end
end

return UIElement
