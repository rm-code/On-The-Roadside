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

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = require( 'src.constants.TileSize' );

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

    function self:init()
        game = Game.new();
        game:init();

        worldPainter = WorldPainter.new( game );
        worldPainter:init();

        userInterface = UserInterface.new( game );
        camera = CameraHandler.new();

        particleLayer = ParticleLayer.new();

        overlayPainter = OverlayPainter.new( particleLayer );

        MousePointer.init( camera );
    end

    function self:draw()
        camera:attach();
        worldPainter:draw();
        overlayPainter:draw();
        camera:detach();
        userInterface:draw();
    end

    function self:update( dt )
        camera:update( dt );
        game:update( dt );
        worldPainter:update( dt );
        overlayPainter:update( dt );
        userInterface:update( dt );
    end

    function self:keypressed( key )
        game:keypressed( key );

        if key == 'i' then
            ScreenManager.push( 'inventory' );
        end
    end

    function self:mousepressed( _, _, button )
        local mx, my = MousePointer.getGridPosition();
        game:mousepressed( mx, my, button );
    end

    Messenger.observe( 'SWITCH_CHARACTERS', function( character )
        camera:setTargetPosition( character:getTile():getX() * TILE_SIZE, character:getTile():getY() * TILE_SIZE );
    end)

    return self;
end

return MainScreen;
