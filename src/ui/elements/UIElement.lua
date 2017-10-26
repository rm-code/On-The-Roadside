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

    -- ------------------------------------------------
    -- Public Attributes
    --
    -- These should never be accessed directly from
    -- outside of this class or any subclasses. Use
    -- setters and getters for that purpose!
    -- ------------------------------------------------

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

    function self:setOrigin( nx, ny )
        self.ox = nx
        self.oy = ny
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

    return self
end

return UIElement
