local Camera = require('lib.Camera');
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

local CameraHandler = {};

local CAMERA_TRACKING_SPEED = 10;
local SCROLL_MARGIN = 15;
local SCROLL_SPEED = 10;

function CameraHandler.new( map )
    local self = Camera.new();

    local tw, th = TexturePacks:getTileDimensions()
    local mw, mh = map:getDimensions()
    local px, py = mw * tw * 0.5, mh * th * 0.5
    local tx, ty = px, py;
    local savedX, savedY;
    local locked;

    ---
    -- Linear interpolation between a and b.
    -- @param a (number) The current value.
    -- @param b (number) The target value.
    -- @param t (number) The time value.
    -- @return  (number) The interpolated value.
    --
    local function lerp( a, b, t )
        return a + ( b - a ) * t;
    end

    local function scroll()
        local mx, my = love.mouse.getPosition();
        local x, y = tx, ty;

        if mx < SCROLL_MARGIN then
            x = x - SCROLL_SPEED;
        elseif mx > love.graphics.getWidth() - SCROLL_MARGIN then
            x = x + SCROLL_SPEED;
        end

        if my < SCROLL_MARGIN then
            y = y - SCROLL_SPEED;
        elseif my > love.graphics.getHeight() - SCROLL_MARGIN then
            y = y + SCROLL_SPEED;
        end

        -- Clamp the camera to the map dimensions.
        tx = math.max( 0, math.min( x, mw * tw ))
        ty = math.max( 0, math.min( y, mh * th ))
    end

    function self:update( dt )
        if not locked then
            scroll();
        end
        px = lerp( px, math.floor( tx / tw ) * tw, dt * CAMERA_TRACKING_SPEED )
        py = lerp( py, math.floor( ty / th ) * th, dt * CAMERA_TRACKING_SPEED )
        self:lookAt( math.floor( px ), math.floor( py ));
    end

    function self:setTargetPosition( dx, dy )
        tx, ty = dx, dy;
    end

    function self:getMousePosition()
        return self:mousepos();
    end

    function self:storePosition()
        savedX, savedY = tx, ty;
    end

    function self:restorePosition()
        if savedX and savedY then
            tx, ty = savedX, savedY;
            savedX, savedY = nil, nil;
        end
    end

    function self:lock()
        locked = true;
    end

    function self:unlock()
        locked = false;
    end

    return self;
end

return CameraHandler;
