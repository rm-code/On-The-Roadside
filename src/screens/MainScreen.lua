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
    end

    function self:mousepressed( _, _, button )
        local mx, my = MousePointer.getGridPosition();
        game:mousepressed( mx, my, button );
    end

    Messenger.observe( 'START_EXECUTION', function()
        camera:lock();
        camera:storePosition();
    end)

    Messenger.observe( 'END_EXECUTION', function()
        camera:unlock();
        camera:restorePosition();
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
