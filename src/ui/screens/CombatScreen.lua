---
-- @module CombatScreen
--

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'lib.screenmanager.Screen' )
local Game = require( 'src.Game' )
local MapPainter = require( 'src.ui.MapPainter' )
local CameraHandler = require('src.ui.CameraHandler')
local MousePointer = require( 'src.ui.MousePointer' )
local UserInterface = require( 'src.ui.UserInterface' )
local OverlayPainter = require( 'src.ui.overlays.OverlayPainter' )
local Messenger = require( 'src.Messenger' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CombatScreen = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function CombatScreen.new()
    local self = Screen.new()

    local game
    local mapPainter
    local userInterface
    local overlayPainter
    local camera
    local observations = {}
    local tw, th = TexturePacks.getTileDimensions()

    function self:init( savegame )
        game = Game.new()
        game:init( savegame )

        mapPainter = MapPainter.new( game )
        mapPainter:init()

        userInterface = UserInterface.new( game )

        camera = CameraHandler.new( game:getMap() )

        overlayPainter = OverlayPainter.new( game )

        MousePointer.init( camera )
    end

    function self:draw()
        camera:attach()
        mapPainter:draw()
        overlayPainter:draw()
        camera:detach()
        userInterface:draw()
    end

    function self:update( dt )
        if self:isActive() then
            camera:update( dt )
        end

        game:update( dt )
        mapPainter:update( dt )
        overlayPainter:update( dt )
        userInterface:update( dt )

        if self:isActive() then
            MousePointer.update()
        end
    end

    function self:keypressed( key, scancode, isrepeat )
        if scancode == 'f' then
            love.window.setFullscreen( not love.window.getFullscreen() )
        end
        if scancode == 'f1' then
            userInterface:toggleDebugInfo()
        end
        if scancode == 'escape' then
            ScreenManager.push( 'ingamemenu', game )
        end

        game:keypressed( key, scancode, isrepeat )
    end

    function self:mousepressed( _, _, button )
        local mx, my = MousePointer.getGridPosition()
        game:mousepressed( mx, my, button )
    end

    function self:mousefocus( f )
        if f then
            camera:unlock()
        else
            camera:lock()
        end
    end

    function self:close()
        for i = 1, #observations do
            Messenger.remove( observations[i] )
        end

        MousePointer.clear()

        game:close()
    end

    observations[#observations + 1] = Messenger.observe( 'SWITCH_CHARACTERS', function( character )
        if not game:getFactions():getPlayerFaction():canSee( character:getTile() ) then
            return
        end
        camera:setTargetPosition( character:getTile():getX() * tw, character:getTile():getY() * th )
    end)

    observations[#observations + 1] = Messenger.observe( 'CHARACTER_MOVED', function( character )
        if not game:getFactions():getPlayerFaction():canSee( character:getTile() ) then
            return
        end
        camera:setTargetPosition( character:getTile():getX() * tw, character:getTile():getY() * th )
    end)

    return self
end

return CombatScreen
