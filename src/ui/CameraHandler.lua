---
-- @module CameraHandler
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Camera = require( 'lib.Camera' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CameraHandler = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local CAMERA_TRACKING_SPEED = 10
local SCROLL_MARGIN = 15
local SCROLL_SPEED = 10

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new CameraHandler instance.
-- @tparam  number mw The map's width.
-- @tparam  number mh The map's height.
-- @treturn CameraHandler A new instance of the CameraHandler class.
--
function CameraHandler.new( mw, mh )
    local self = Camera.new()

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local tw, th = TexturePacks:getTileDimensions()
    local px, py = mw * tw * 0.5, mh * th * 0.5
    local tx, ty = px, py
    local locked

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Linear interpolation between a and b.
    -- @tparam  number a The current value.
    -- @tparam  number b The target value.
    -- @tparam  number t The time value.
    -- @treturn number   The interpolated value.
    --
    local function lerp( a, b, t )
        return a + ( b - a ) * t
    end

    ---
    -- Scrolls the camera if the mouse pointer reaches the edges of the screen.
    --
    local function scroll()
        local mx, my = love.mouse.getPosition()
        local x, y = tx, ty

        if mx < SCROLL_MARGIN then
            x = x - SCROLL_SPEED
        elseif mx > love.graphics.getWidth() - SCROLL_MARGIN then
            x = x + SCROLL_SPEED
        end

        if my < SCROLL_MARGIN then
            y = y - SCROLL_SPEED
        elseif my > love.graphics.getHeight() - SCROLL_MARGIN then
            y = y + SCROLL_SPEED
        end

        -- Clamp the camera to the map dimensions.
        tx = math.max( 0, math.min( x, mw * tw ))
        ty = math.max( 0, math.min( y, mh * th ))
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Updates the camera's scrolling, by lerping the camera's current position
    -- to the target position.
    -- @tparam number dt The time since the last frame.
    --
    -- @see setTargetPosition
    --
    function self:update( dt )
        if not locked then
            scroll()
        end
        px = lerp( px, math.floor( tx / tw ) * tw, dt * CAMERA_TRACKING_SPEED )
        py = lerp( py, math.floor( ty / th ) * th, dt * CAMERA_TRACKING_SPEED )
        self:lookAt( math.floor( px ), math.floor( py ))
    end

    ---
    -- Locks the camera to prevent scrolling.
    --
    function self:lock()
        locked = true
    end

    ---
    -- Unlocks the camera and re-enables scrolling.
    --
    function self:unlock()
        locked = false
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the position of the mouse pointer.
    -- @treturn number The x coordinate of the mouse pointer.
    -- @treturn number The y coordinate of the mouse pointer.
    --
    function self:getMousePosition()
        return self:mousepos()
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    ---
    -- Sets the target position for the camera. This will not move the camera
    -- directly. Use the update function to lerp the current camera position
    -- to the target position.
    -- @tparam number The new position along the x axis.
    -- @tparam number The new position along the y axis.
    --
    -- @see update
    --
    function self:setTargetPosition( dx, dy )
        tx, ty = dx, dy
    end

    return self
end

return CameraHandler
