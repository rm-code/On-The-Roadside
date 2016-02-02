local Screen = require( 'lib.screenmanager.Screen' );
local Map = require( 'src.map.Map' );
local Character = require( 'src.characters.Character' );
local TurnManager = require( 'src.combat.TurnManager' );

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
    CHARACTER = love.graphics.newQuad( 1 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILESET:getDimensions() );
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local characters;
    local turnManager;
    local map;

    function self:init()
        map = Map.new();
        map:init();

        characters = {
            Character.new( map:getTileAt( love.math.random( 2, 30 ), love.math.random( 2, 30 )));
            Character.new( map:getTileAt( love.math.random( 2, 30 ), love.math.random( 2, 30 )));
            Character.new( map:getTileAt( love.math.random( 2, 30 ), love.math.random( 2, 30 )));
            Character.new( map:getTileAt( love.math.random( 2, 30 ), love.math.random( 2, 30 )));
            Character.new( map:getTileAt( love.math.random( 2, 30 ), love.math.random( 2, 30 )));
            Character.new( map:getTileAt( love.math.random( 2, 30 ), love.math.random( 2, 30 )));
            Character.new( map:getTileAt( love.math.random( 2, 30 ), love.math.random( 2, 30 )));
        };

        turnManager = TurnManager.new( map, characters );
    end

    function self:draw()
        map:iterate( function( tile, x, y )
            if tile:isOccupied() then
                love.graphics.draw( TILESET, TILE_SPRITES.CHARACTER, x * TILE_SIZE, y * TILE_SIZE )
            else
                if tile:getWorldObject():getType() == 'Floor' then
                    love.graphics.draw( TILESET, TILE_SPRITES.FLOOR, x * TILE_SIZE, y * TILE_SIZE )
                elseif tile:getWorldObject():getType() == 'Wall' then
                    love.graphics.draw( TILESET, TILE_SPRITES.WALL, x * TILE_SIZE, y * TILE_SIZE )
                end
            end
        end);

        local mx, my = love.mouse.getPosition();
        love.graphics.rectangle( 'line', math.floor( mx / TILE_SIZE ) * TILE_SIZE, math.floor( my / TILE_SIZE ) * TILE_SIZE, TILE_SIZE, TILE_SIZE )
    end

    function self:update( dt )
        turnManager:update( dt )
    end

    function self:keypressed( key )
        turnManager:keypressed( key );
    end

    function self:mousepressed( mx, my, button )
        local gx, gy = math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE );
        turnManager:mousepressed( gx, gy, button );
    end

    return self;
end

return MainScreen;
