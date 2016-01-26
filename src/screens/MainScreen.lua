local Screen = require( 'lib.screenmanager.Screen' );
local Map = require( 'src.map.Map' );
local Character = require( 'src.characters.Character' );
local Walk = require( 'src.characters.actions.Walk' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.enums.Direction' );

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

    local player;
    local map;

    function self:init()
        map = Map.new();
        map:init();

        player = Character.new( map:getTileAt( 2, 2 ));
    end

    function self:draw()
        map:iterate( function( tile, x, y )
            if tile:isOccupied() then
                love.graphics.draw( TILESET, TILE_SPRITES.CHARACTER, x * TILE_SIZE, y * TILE_SIZE )
            else
                if tile:getType() == 'floor' then
                    love.graphics.draw( TILESET, TILE_SPRITES.FLOOR, x * TILE_SIZE, y * TILE_SIZE )
                elseif tile:getType() == 'wall' then
                    love.graphics.draw( TILESET, TILE_SPRITES.WALL, x * TILE_SIZE, y * TILE_SIZE )
                end
            end
        end);
    end

    function self:update()
        if player:getAction() then
            player:getAction():perform();
        end
    end

    function self:keypressed( key )
        if key == 'w' then
            player:setAction( Walk.new( player, player:getTile():getNeighbours()[DIRECTION.NORTH] ));
        elseif key == 'x' then
            player:setAction( Walk.new( player, player:getTile():getNeighbours()[DIRECTION.SOUTH] ));
        elseif key == 'a' then
            player:setAction( Walk.new( player, player:getTile():getNeighbours()[DIRECTION.WEST] ));
        elseif key == 'd' then
            player:setAction( Walk.new( player, player:getTile():getNeighbours()[DIRECTION.EAST] ));
        elseif key == 'q' then
            player:setAction( Walk.new( player, player:getTile():getNeighbours()[DIRECTION.NORTH_WEST] ));
        elseif key == 'e' then
            player:setAction( Walk.new( player, player:getTile():getNeighbours()[DIRECTION.NORTH_EAST] ));
        elseif key == 'y' then
            player:setAction( Walk.new( player, player:getTile():getNeighbours()[DIRECTION.SOUTH_WEST] ));
        elseif key == 'c' then
            player:setAction( Walk.new( player, player:getTile():getNeighbours()[DIRECTION.SOUTH_EAST] ));
        end
    end

    return self;
end

return MainScreen;
