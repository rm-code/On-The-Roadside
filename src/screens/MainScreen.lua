local Screen = require( 'lib.screenmanager.Screen' );
local Game = require( 'src.Game' );
local WorldPainter = require( 'src.ui.WorldPainter' );

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

    function self:init()
        game = Game.new();
        game:init();

        worldPainter = WorldPainter.new( game );
        worldPainter.init();
    end

    function self:draw()
        worldPainter.draw();
    end

    function self:update( dt )
        game:update( dt );
        worldPainter.update( dt );
    end

    function self:keypressed( key )
        game:keypressed( key );
    end

    function self:mousepressed( mx, my, button )
        game:mousepressed( mx, my, button );
    end

    return self;
end

return MainScreen;
