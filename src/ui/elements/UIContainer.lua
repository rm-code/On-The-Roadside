---
-- The UIContainer module takes care of correctly forwarding keyboard and
-- mouse input to registered UIElements. It can be used to allow the player
-- to tab between UIElements.
--
-- @module UIContainer
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local UIElement = require( 'src.ui.elements.UIElement' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIContainer = Class( 'UIContainer' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIContainer:initialize()
    self.list = {}
    self.current = 1
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Registers a new UIElement.
-- @tparam UIElement element The UIElement to register.
--
function UIContainer:register( element )
    assert( element:isInstanceOf( UIElement ), 'Expected an object of type UIElement.' )
    self.list[#self.list + 1] = element

    -- The first element in this list will be focused.
    self.list[self.current]:setFocus( true )
end

---
-- Draws all registered UIElements.
--
function UIContainer:draw()
    for i = 1, #self.list do
        self.list[i]:draw()
    end
end

---
-- Updates all registered UIElements and handles mouse hovering.
--
function UIContainer:update()
    for i = 1, #self.list do
        self.list[i]:update()
    end

    if not love.mouse.isVisible() then
        return
    end

    self.current = nil

    for i = 1, #self.list do
        self.list[i]:setFocus( false )
        if self.list[i]:isMouseOver() then
            self.list[i]:setFocus( true  )
            self.current = i
        end
    end
end

---
-- Select the next registered UIElement and focus it.
--
function UIContainer:next()
    love.mouse.setVisible( false )
    if self.current then
        self.list[self.current]:setFocus( false )
        self.current = self.current + 1
        self.current = self.current > #self.list and 1 or self.current
    else
        self.current = 1
    end
    self.list[self.current]:setFocus( true )
end

---
-- Fowards a command to the currently focused UIElement.
-- @tparam string cmd The command to forward.
--
function UIContainer:command( cmd )
    if self.current then
        self.list[self.current]:command( cmd )
    else
        self:next()
    end
end

---
-- Fowards a command to the currently focused UIElement.
-- @tparam string cmd The command to forward.
--
function UIContainer:mousecommand( cmd )
    if not self.current then
        return
    end
    self.list[self.current]:mousecommand( cmd )
end

return UIContainer
