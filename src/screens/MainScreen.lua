local Screen = require( 'lib.screenmanager.Screen' );
local Map = require( 'src.map.Map' );
local CharacterManager = require( 'src.characters.CharacterManager' );
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

    local turnManager;
    local map;

    function self:init()
        map = Map.new();
        map:init();

        CharacterManager.newCharacter( map:getTileAt( 2, 2 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 3 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 4 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 5 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 6 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 7 ));
        CharacterManager.newCharacter( map:getTileAt( 2, 8 ));

        turnManager = TurnManager.new( map );
    end

    function self:draw()
        map:iterate( function( tile, x, y )
            if tile:isOccupied() then
                love.graphics.setColor( 255, 180, 80 );
                love.graphics.draw( TILESET, TILE_SPRITES.CHARACTER, x * TILE_SIZE, y * TILE_SIZE )
                love.graphics.setColor( 255, 255, 255 );
            else
                if tile:getWorldObject():getType() == 'Floor' then
                    love.graphics.setColor( 150, 150, 150 );
                    love.graphics.draw( TILESET, TILE_SPRITES.FLOOR, x * TILE_SIZE, y * TILE_SIZE )
                elseif tile:getWorldObject():getType() == 'Wall' then
                    love.graphics.setColor( 190, 190, 190 );
                    love.graphics.draw( TILESET, TILE_SPRITES.WALL, x * TILE_SIZE, y * TILE_SIZE )
                end
            end
            love.graphics.setColor( 255, 255, 255 );
        end);

        local selectedCharX, selectedCharY = CharacterManager.getCurrentCharacter():getTile():getPosition();
        love.graphics.setColor( 0, 255, 0 );
        love.graphics.rectangle( 'line', selectedCharX * TILE_SIZE, selectedCharY * TILE_SIZE, TILE_SIZE, TILE_SIZE );

        local mx, my = love.mouse.getPosition();
        love.graphics.setColor( 255, 255, 255 );
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
