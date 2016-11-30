local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local Game = require( 'src.Game' );
local WorldPainter = require( 'src.ui.WorldPainter' );
local CameraHandler = require('src.ui.CameraHandler');
local MousePointer = require( 'src.ui.MousePointer' );
local UserInterface = require( 'src.ui.UserInterface' );
local ParticleLayer = require( 'src.ui.ParticleLayer' );
local OverlayPainter = require( 'src.ui.OverlayPainter' );
local Messenger = require( 'src.Messenger' );
local Tileset = require( 'src.ui.Tileset' );
local Translator = require( 'src.util.Translator' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = require( 'src.constants.TileSize' );
local DEFAULT_LOCALE = 'en_EN';

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local game;
    local worldPainter;
    local userInterface;
    local particleLayer;
    local overlayPainter;
    local camera;

    local exitTimer;

    function self:init()
        exitTimer = 0;

        Translator.init( DEFAULT_LOCALE );

        game = Game.new();
        game:init();

        Tileset.init( 'res/img/16x16_sm.png', TILE_SIZE );

        worldPainter = WorldPainter.new( game );
        worldPainter:init();

        userInterface = UserInterface.new( game );
        camera = CameraHandler.new( game:getMap(), game.getCurrentCharacter():getTile():getX() * TILE_SIZE, game.getCurrentCharacter():getTile():getY() * TILE_SIZE );

        particleLayer = ParticleLayer.new();

        overlayPainter = OverlayPainter.new( game, particleLayer );

        MousePointer.init( camera );
    end

    function self:draw()
        camera:attach();
        worldPainter:draw();
        overlayPainter:draw();
        camera:detach();
        userInterface:draw();

        if exitTimer ~= 0 then
            love.graphics.setColor( 0, 0, 0, 255 * exitTimer );
            love.graphics.rectangle( 'fill', 0, 0, love.graphics.getDimensions() );
            love.graphics.setColor( 255, 255, 255, 255 );
        end
    end

    function self:update( dt )
        camera:update( dt );
        game:update( dt );
        worldPainter:update( dt );
        overlayPainter:update( dt );
        userInterface:update( dt );

        if love.keyboard.isDown( 'escape' ) then
            exitTimer = exitTimer + dt * 2;
            if exitTimer >= 1.0 then
                love.event.quit();
            end
        else
            exitTimer = 0;
        end
    end

    function self:keypressed( key )
        if key == 'f' then
            love.window.setFullscreen( not love.window.getFullscreen() );
        end
        if key == 'h' then
            ScreenManager.push( 'help' );
        end

        game:keypressed( key );
    end

    function self:mousepressed( _, _, button )
        local mx, my = MousePointer.getGridPosition();
        game:mousepressed( mx, my, button );
    end

    function self:mousefocus( f )
        if f then
            camera:unlock();
        else
            camera:lock();
        end
    end

    Messenger.observe( 'START_EXECUTION', function()
        camera:lock();
        camera:storePosition();
    end)

    Messenger.observe( 'END_EXECUTION', function( restore )
        camera:unlock();
        if restore then
            camera:restorePosition();
        end
    end)

    Messenger.observe( 'SWITCH_CHARACTERS', function( character )
        if not game:getFactions():getPlayerFaction():canSee( character:getTile() ) or character:getFaction():isAIControlled() then
            return;
        end
        camera:setTargetPosition( character:getTile():getX() * TILE_SIZE, character:getTile():getY() * TILE_SIZE );
    end)

    Messenger.observe( 'CHARACTER_MOVED', function( character )
        if not game:getFactions():getPlayerFaction():canSee( character:getTile() ) or character:getFaction():isAIControlled() then
            return;
        end
        camera:setTargetPosition( character:getTile():getX() * TILE_SIZE, character:getTile():getY() * TILE_SIZE );
    end)

    Messenger.observe( 'START_ATTACK', function( target )
        if not game:getFactions():getPlayerFaction():canSee( target ) then
            return;
        end
        camera:setTargetPosition( target:getX() * TILE_SIZE, target:getY() * TILE_SIZE );
    end)

    return self;
end

return MainScreen;
