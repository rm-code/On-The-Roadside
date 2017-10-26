---
-- Creates an opaque background of a certain height and width.
--
-- @module UIBackground
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIBackground = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new UIBackground.
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
function UIBackground.new( px, py, rx, ry, w, h )
    local self = UIElement.new( px, py, rx, ry, w, h ):addInstance( 'UIBackground' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local color = 'sys_background'

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Initialises the UIBackground object.
    -- @tparam string ncolor The color ID to use for drawing the background.
    --
    function self:init( ncolor )
        color = ncolor
    end

    ---
    -- Draws the background starting at the specified position.
    --
    function self:draw()
        local tw, th = TexturePacks.getTileDimensions()
        TexturePacks.setColor( color )
        love.graphics.rectangle( 'fill', self.ax * tw, self.ay * th, self.w * tw, self.h * th )
        TexturePacks.resetColor()
    end

    ---
    -- Changes the color used for drawing the background.
    -- @tparam string ncolor The color ID to use for drawing the background.
    --
    function self:setColor( ncolor )
        color = ncolor
    end

    return self
end

return UIBackground
