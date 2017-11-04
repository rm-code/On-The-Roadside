---
-- The parent class for all UI elements.
-- @module UIElement
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Observable = require( 'src.util.Observable' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIElement = {}

-- ------------------------------------------------
-- Constructor
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
function UIElement.new( ox, oy, rx, ry, w, h )
    local self = Observable.new():addInstance( 'UIElement' )

    local focus = false

    -- ------------------------------------------------
    -- Public Attributes
    --
    -- These should never be accessed directly from
    -- outside of this class or any subclasses. Use
    -- setters and getters for that purpose!
    -- ------------------------------------------------

    self.children = {}

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

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:addChild( child )
        if not child:instanceOf( 'UIElement' ) then
            error( 'Children of a UIElement must be derived from the UIElement class themselves.' )
        end
        self.children[#self.children + 1] = child
    end

    function self:clearChildren()
        self.children = {}
    end

    ---
    -- Sets the origin for this UIElement and updates the absolute position
    -- accordingly.
    -- @tparam number nx The new origin along the x-axis.
    -- @tparam number ny The new origin along the y-axis.
    --
    function self:setOrigin( nx, ny )
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
    function self:setRelativePosition( nx, ny )
        self.rx = nx
        self.ry = ny
        self.ax = self.ox + self.rx
        self.ay = self.oy + self.ry
    end

    ---
    -- Checks wether or not the mouse cursor is over this element.
    -- @treturn boolean True if the mouse is within this element's bounds.
    --
    function self:isMouseOver()
        local mx, my = love.mouse.getPosition()
        local gx, gy = GridHelper.pixelsToGrid( mx, my )
        return  gx >= self.ox + self.rx
            and gx <  self.ox + self.rx + self.w
            and gy >= self.oy + self.ry
            and gy <  self.oy + self.ry + self.h
    end

    ---
    -- Sets the focus for this UIElement. Focus should be used as a way to
    -- mark UIElements which should receive keypresses and are the "current"
    -- point of focus for the player.
    -- @tparam boolean nfocus The new focus value.
    --
    function self:setFocus( nfocus )
        focus = nfocus
    end

    ---
    -- Checks wether this UIElement has focus or not.
    -- @treturn boolean True if the element has focus.
    --
    function self:hasFocus()
        return focus
    end

    return self
end

return UIElement
