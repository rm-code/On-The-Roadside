local Screen = require( 'lib.screenmanager.Screen' );
local Map = require( 'src.map.Map' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = 16;
local TILESET = love.graphics.newImage( 'res/tiles/16x16_sm.png' );
local TILE_SPRITES = {
    FLOOR = love.graphics.newQuad( 14 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
    WALL  = love.graphics.newQuad(  3 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local map;

    function self:init()
        map = Map.new();
        map:init();
    end

    function self:draw()
        map:iterate( function( tile, x, y )
            if tile:getType() == 'floor' then
                love.graphics.draw( TILESET, TILE_SPRITES.FLOOR, x * TILE_SIZE, y * TILE_SIZE )
            elseif tile:getType() == 'wall' then
                love.graphics.draw( TILESET, TILE_SPRITES.WALL, x * TILE_SIZE, y * TILE_SIZE )
            end
        end);
    end

    return self;
end

return MainScreen;
