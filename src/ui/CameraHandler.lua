local Camera = require('lib.Camera');

local CameraHandler = {};

local CAMERA_TRACKING_SPEED = 10;
local SCROLL_MARGIN = 5;
local SCROLL_SPEED = 10;

function CameraHandler.new( map, px, py )
    local self = Camera.new();

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

        -- Clamp the camera to the map dimensions.
        local w, h = map:getPixelDimensions();
        tx = math.max( 0, math.min( x, w ));
        ty = math.max( 0, math.min( y, h ));
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
