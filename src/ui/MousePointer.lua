local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

local MousePointer = {}

local camera;

local mx, my;
local gx, gy;
local wx, wy;
local tw, th

function MousePointer.init( ncamera )
    camera = ncamera;

    tw, th = TexturePacks.getTileDimensions()

    love.mouse.setPosition( love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5 );

    mx, my = love.mouse.getPosition();
    wx, wy = camera:worldCoords( mx, my );
    gx, gy = math.floor( mx / tw ), math.floor( my / th )
end

function MousePointer.update()
    mx, my = camera:mousepos();
    wx, wy = camera:worldCoords( love.mouse.getPosition() );
    gx, gy = math.floor( mx / tw ), math.floor( my / th )
end

function MousePointer.clear()
    camera = nil;
end

function MousePointer.getWorldPosition()
    return wx, wy;
end

function MousePointer.getGridPosition()
    return gx, gy;
end

return MousePointer;
