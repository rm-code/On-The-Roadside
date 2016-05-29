local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local Game = require( 'src.Game' );
local WorldPainter = require( 'src.ui.WorldPainter' );
local InputHandler = require( 'src.ui.InputHandler' );
local ItemFactory = require( 'src.items.ItemFactory' );
local TileFactory = require( 'src.map.tiles.TileFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );
local SoundManager = require( 'src.SoundManager' );

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

    function self:init()
        ItemFactory.loadTemplates();
        TileFactory.loadTemplates();
        WorldObjectFactory.loadTemplates();
        SoundManager.loadResources();

        game = Game.new();
        game:init();

        worldPainter = WorldPainter.new( game );
        worldPainter.init();

        inputHandler = InputHandler.new( game );
    end

    function self:draw()
        worldPainter.draw();
    end

    function self:update( dt )
        inputHandler:update( dt );
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
