local MousePointer = {};

local TILE_SIZE = require( 'src.constants.TileSize' );

local camera;

love.mouse.setPosition( love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5 );

function MousePointer.init( ncamera )
    camera = ncamera;
end

function MousePointer.getWorldPosition( x, y )
    return camera:worldCoords( x, y );
end

function MousePointer.getCameraPosition( x, y )
    return camera:cameraCoords( x, y );
end

function MousePointer.getGridPosition()
    local mx, my = camera:mousepos();
    return math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE );
end

return MousePointer;
