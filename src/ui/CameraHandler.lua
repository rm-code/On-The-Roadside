local Camera = require('lib.Camera');

local CameraHandler = {};

local CAMERA_TRACKING_SPEED = 10;
local SCROLL_MARGIN = 5;
local SCROLL_SPEED = 10;

function CameraHandler.new()
    local self = Camera.new();

    local px, py = love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5;
    local tx, ty = px, py;

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

        tx, ty = x, y;
    end

    function self:update( dt )
        scroll()
        px = lerp( px, tx, dt * CAMERA_TRACKING_SPEED );
        py = lerp( py, ty, dt * CAMERA_TRACKING_SPEED );
        self:lookAt( math.floor( px ), math.floor( py ));
    end

    function self:setTargetPosition( dx, dy )
        tx, ty = dx, dy;
    end

    function self:getMousePosition()
        return self:mousepos();
    end

    return self;
end

return CameraHandler;
