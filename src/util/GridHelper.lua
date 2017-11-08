---
-- @module GridHelper
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GridHelper = {}

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Returns the screen dimensions in grid space.
-- @treturn number The screen's width in grid space.
-- @treturn number The screen's height in grid space.
--
function GridHelper.getScreenGridDimensions()
    local tw, th = TexturePacks.getTileDimensions()
    local sw, sh = love.graphics.getDimensions()
    return math.floor( sw / tw ), math.floor( sh / th )
end

---
-- Calculate the parts of the screen which don't fit in the grid space.
-- @treturn number The overflow along the x-axis in pixels.
-- @treturn number The overflow along the y-axis in pixels.
--
function GridHelper.getScreenOverflow()
    local sw, sh = love.graphics.getDimensions()
    local tw, th = TexturePacks.getTileDimensions()
    return sw % tw, sh % th
end

---
-- Calculates the coordinates to be used to center an UI element of the
-- given dimensions.
-- @tparam  number w The grid width of the UI element to center.
-- @tparam  number h The grid height of the UI element to center.
-- @treturn number   The coordinate in grid space along the x-axis.
-- @treturn number   The coordinate in grid space along the y-axis.
--
function GridHelper.centerElement( w, h )
    local sw, sh = GridHelper.getScreenGridDimensions()
    return math.floor(( sw-w ) * 0.5 ), math.floor(( sh-h ) * 0.5 )
end

---
-- Maps a pixel coordinate to the grid space.
-- @tparam  number x The position in pixels along the x-axis.
-- @tparam  number y The position in pixels along the y-axis.
-- @treturn number   The coordinate in grid space along the x-axis.
-- @treturn number   The coordinate in grid space along the y-axis.
--
function GridHelper.pixelsToGrid( x, y )
    local tw, th = TexturePacks.getTileDimensions()
    return math.floor( x / tw ), math.floor( y / th )
end

---
-- Takes a grid coordinate and constrains it to the screen's grid space.
-- @tparam  number gx The grid coordinate along the x-axis.
-- @tparam  number gy The grid coordinate along the y-axis.
-- @treturn number    The adjusted coordinate along the x-axis.
-- @treturn number    The adjusted coordinate along the y-axis.
--
function GridHelper.constrainToGrid( gx, gy )
    local sw, sh = GridHelper.getScreenGridDimensions()
    return math.min( gx, sw-1 ), math.min( gy, sh-1 )
end

---
-- Gets the mouse cursor's position on the screen grid. The coordinates will be
-- limited to the rounded screen grid size (only fully drawn tiles are counted).
-- Use this for mouse input on the User Interface.
-- @treturn number The mouse cursor's position along the x-axis.
-- @treturn number The mouse cursor's position along the y-axis.
--
function GridHelper.getMouseGridPosition()
    return GridHelper.constrainToGrid( GridHelper.pixelsToGrid( love.mouse.getPosition() ))
end

return GridHelper
