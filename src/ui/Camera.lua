---
-- @module Camera
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local GridHelper = require( 'src.util.GridHelper' )
local Util = require( 'src.util.Util' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Camera = Class( 'Camera' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local CAMERA_TRACKING_SPEED = 10
local SCROLL_MARGIN = 15
local SCROLL_SPEED = 10

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
-- @tparam  number tx The camera's current target position along the x-axis.
-- @tparam  number ty The camera's current target position along the y-axis.
-- @tparam  number mw The map's width.
-- @tparam  number mh The map's height.
-- @tparam  number tw The width of the tiles used for map drawing.
-- @tparam  number th The height of the tiles used for map drawing.
--
local function scroll( tx, ty, mw, tw, mh, th )
    local mx, my = love.mouse.getPosition()

    if mx < SCROLL_MARGIN then
        tx = tx - SCROLL_SPEED
    elseif mx > love.graphics.getWidth() - SCROLL_MARGIN then
        tx = tx + SCROLL_SPEED
    end

    if my < SCROLL_MARGIN then
        ty = ty - SCROLL_SPEED
    elseif my > love.graphics.getHeight() - SCROLL_MARGIN then
        ty = ty + SCROLL_SPEED
    end

    -- Clamp the camera to the map dimensions.
    return Util.clamp( 0, tx, mw * tw ), Util.clamp( 0, ty, mh * th )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new Camera instance.
-- @tparam  number mw The map's width.
-- @tparam  number mh The map's height.
-- @tparam  number tw The width of the tiles used for map drawing.
-- @tparam  number th The height of the tiles used for map drawing.
-- @treturn Camera A new instance of the Camera class.
--
function Camera:initialize( mw, mh, tw, th )
    self.centerX, self.centerY = love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5

    self.mw, self.mh, self.tw, self.th = mw, mh, tw, th

    -- The camera's target coordinates.
    self.tx, self.ty = mw * tw * 0.5, mh * th * 0.5

    -- The camera's current position, which will be updated each frame to move
    -- towards the target coordinates.
    self.cx, self.cy = self.tx, self.ty
end

---
-- Attaches the camera which translates the game's coordinate system. Everything
-- drawn after this will be offset according to the camera's position.
--
function Camera:attach()
    self.centerX, self.centerY = love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5

    love.graphics.push()
    love.graphics.translate( self.centerX - self.cx, self.centerY - self.cy )
end

---
-- Detaches the camera and resets the coordinate system.
--
function Camera:detach()
    love.graphics.pop()
end

---
-- Updates the camera's scrolling, by lerping the camera's current position
-- to the target position.
-- @tparam number dt The time since the last frame.
--
-- @see setTargetPosition
--
function Camera:update( dt )
    if not self.locked then
        self.tx, self.ty = scroll( self.tx, self.ty, self.mw, self.tw, self.mh, self.th )
    end

    self.cx = math.floor( lerp( self.cx, math.floor( self.tx / self.tw ) * self.tw, dt * CAMERA_TRACKING_SPEED ))
    self.cy = math.floor( lerp( self.cy, math.floor( self.ty / self.th ) * self.th, dt * CAMERA_TRACKING_SPEED ))
end

---
-- Locks the camera to prevent scrolling.
--
function Camera:lock()
    self.locked = true
end

---
-- Unlocks the camera and re-enables scrolling.
--
function Camera:unlock()
    self.locked = false
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets the target position for the camera. This will not move the camera
-- directly. Use the update function to lerp the current camera position
-- to the target position.
-- @tparam number nx The new position along the x axis.
-- @tparam number ny The new position along the y axis.
--
-- @see update
--
function Camera:setTargetPosition( nx, ny )
    self.tx, self.ty = nx, ny
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the mouse position on the game's grid manipulated by the camera's
-- coordinate system. Use this for any mouse interactions with the actual
-- game world (map, objects, etc.).
-- @treturn number The mouse cursor's position along the x-axis.
-- @treturn number The mouse cursor's position along the y-axis.
--
function Camera:getMouseWorldGridPosition()
    local mx, my = love.mouse.getPosition()
    mx, my = ( mx - self.centerX ) + self.cx, ( my - self.centerY ) + self.cy
    return GridHelper.pixelsToGrid( mx, my )
end

return Camera
