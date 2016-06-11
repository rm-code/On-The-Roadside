local Camera = require('lib.Camera');

local CameraHandler = {};

local SCROLL_MARGIN = 5;
local SCROLL_SPEED = 10;

function CameraHandler.new()
    local self = Camera.new();

    local x, y = love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5;

    local function scroll()
        local mx, my = love.mouse.getPosition();

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
    end

    function self:update()
        scroll()
        self:lookAt( x, y );
    end

    function self:getMousePosition()
        return self:mousepos();
    end

    return self;
end

return CameraHandler;
