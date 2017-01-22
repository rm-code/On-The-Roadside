local MousePointer = {};

local TILE_SIZE = require( 'src.constants.TileSize' );

local camera;

local mx, my;
local gx, gy;
local wx, wy;

function MousePointer.init( ncamera )
    camera = ncamera;

    love.mouse.setPosition( love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5 );

    mx, my = love.mouse.getPosition();
    wx, wy = camera:worldCoords( mx, my );
    gx, gy = math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE );
end

function MousePointer.update()
    mx, my = camera:mousepos();
    wx, wy = camera:worldCoords( love.mouse.getPosition() );
    gx, gy = math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE );
end

function MousePointer.getWorldPosition()
    return wx, wy;
end

function MousePointer.getGridPosition()
    return gx, gy;
end

return MousePointer;
