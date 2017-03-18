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

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GameScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function GameScreen.new()
    local self = Screen.new();

    local game;
    local worldPainter;
    local userInterface;
    local particleLayer;
    local overlayPainter;
    local camera;
    local observations = {};

    local exitTimer;

    function self:init( savegame )
        exitTimer = 0;

        game = Game.new();
        game:init( savegame );

        Tileset.init( 'res/img/16x16_sm.png', TILE_SIZE );

        worldPainter = WorldPainter.new( game );
        worldPainter:init();

        userInterface = UserInterface.new( game );

        camera = CameraHandler.new( game:getMap() );

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
        if self:isActive() then
            camera:update( dt );
        end

        game:update( dt );
        worldPainter:update( dt );
        overlayPainter:update( dt );
        userInterface:update( dt );

        if self:isActive() then
            MousePointer.update();
        end

        if love.keyboard.isScancodeDown( 'escape' ) then
            exitTimer = exitTimer + dt * 2;
            if exitTimer >= 1.0 then
                ScreenManager.switch( 'mainmenu' );
            end
        else
            exitTimer = 0;
        end
    end

    function self:keypressed( key, scancode, isrepeat )
        if scancode == 'f' then
            love.window.setFullscreen( not love.window.getFullscreen() );
        end
        if scancode == 'h' then
            ScreenManager.push( 'help' );
        end
        if scancode == 'f1' then
            userInterface:toggleDebugInfo();
        end

        game:keypressed( key, scancode, isrepeat );
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

    function self:close()
        for i = 1, #observations do
            Messenger.remove( observations[i] );
        end

        MousePointer.clear();

        game:close();
    end

    observations[#observations + 1] = Messenger.observe( 'SWITCH_CHARACTERS', function( character )
        if not game:getFactions():getPlayerFaction():canSee( character:getTile() ) then
            return;
        end
        camera:setTargetPosition( character:getTile():getX() * TILE_SIZE, character:getTile():getY() * TILE_SIZE );
    end)

    observations[#observations + 1] = Messenger.observe( 'CHARACTER_MOVED', function( character )
        if not game:getFactions():getPlayerFaction():canSee( character:getTile() ) then
            return;
        end
        camera:setTargetPosition( character:getTile():getX() * TILE_SIZE, character:getTile():getY() * TILE_SIZE );
    end)

    return self;
end

return GameScreen;
