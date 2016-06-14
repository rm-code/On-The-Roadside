local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local Game = require( 'src.Game' );
local WorldPainter = require( 'src.ui.WorldPainter' );
local InputHandler = require( 'src.ui.InputHandler' );
local CameraHandler = require('src.ui.CameraHandler');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local game;
    local worldPainter;
    local inputHandler;
    local camera;

    function self:init()
        game = Game.new();
        game:init();

        worldPainter = WorldPainter.new( game );
        worldPainter.init();

        inputHandler = InputHandler.new( game );

        camera = CameraHandler.new();
    end

    function self:draw()
        camera:attach();
        worldPainter.draw();
        camera:detach();
    end

    function self:update( dt )
        camera:update( dt );
        inputHandler:update( camera:getMousePosition() );
        game:update( dt );
        worldPainter.update( dt );
    end

    function self:keypressed( key )
        inputHandler:keypressed( key );

        if key == 'i' then
            ScreenManager.push( 'inventory' );
        end
    end

    function self:mousepressed( mx, my, button )
        inputHandler:mousepressed( mx, my, button );
    end

    return self;
end

return MainScreen;
