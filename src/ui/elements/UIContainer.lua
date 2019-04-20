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
local Util = require( 'src.util.Util' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIContainer = Class( 'UIContainer' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Scrolls to the next / previous UIElement in the list. Automatically selects
-- the first element in the list if none is selected yet. Also wraps to the
-- first / last item if the end of the list is reached.
-- @tparam  number current   The index pointing to the currently active item in the list.
-- @tparam  table  list      The sequence containing the registered UIElements.
-- @tparam  number direction The direction to scroll into (-1 = previous, 1 = next).
-- @treturn number           The updated "current" index.
--
local function scroll( current, list, direction )
    love.mouse.setVisible( false )

    current = current or 1

    list[current]:setFocus( false )
    current = Util.wrap( 1, current + direction, #list )
    list[current]:setFocus( true )

    return current
end

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
-- Selects the previous registered UIElement and focuses it.
-- If no UIElement is currently selected, it will select the first one in the list.
--
function UIContainer:prev()
    self.current = scroll( self.current, self.list, -1 )
end

---
-- Selects the next registered UIElement and focuses it.
-- If no UIElement is currently selected, it will select the first one in the list.
--
function UIContainer:next()
    self.current = scroll( self.current, self.list, 1 )
end

---
-- Fowards a command to the currently focused UIElement.
-- If no UIElement is currently focused it selects the next one, but doesn't
-- send the command.
--
-- @tparam string cmd The command to forward.
--
function UIContainer:command( cmd )
    if not self.current then
        self:next()
        return
    end

    self.list[self.current]:command( cmd )
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

---
-- Checks if the UIContainer has focus. This is the case if one of the
-- registered UIElements has focus.
-- @treturn boolean True if one of the UIElements has focus, false otherwise.
--
function UIContainer:hasFocus()
    for i = 1, #self.list do
        if self.list[i]:hasFocus() then
            return true
        end
    end
    return false
end

return UIContainer
