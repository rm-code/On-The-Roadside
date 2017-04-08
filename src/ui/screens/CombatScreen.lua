---
-- @module CombatScreen
--

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'lib.screenmanager.Screen' )
local CombatState = require( 'src.CombatState' )
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

    local combatState
    local mapPainter
    local userInterface
    local overlayPainter
    local camera
    local observations = {}
    local tw, th = TexturePacks.getTileDimensions()

    function self:init( savegame )
        combatState = CombatState.new()
        combatState:init( savegame )

        mapPainter = MapPainter.new()
        mapPainter:init( combatState:getMap(), combatState:getFactions() )

        userInterface = UserInterface.new( combatState )

        camera = CameraHandler.new( combatState:getMap() )

        overlayPainter = OverlayPainter.new( combatState )

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

        combatState:update( dt )
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
            ScreenManager.push( 'ingamemenu', combatState )
        end

        combatState:keypressed( key, scancode, isrepeat )
    end

    function self:mousepressed( _, _, button )
        local mx, my = MousePointer.getGridPosition()
        combatState:mousepressed( mx, my, button )
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

        combatState:close()
    end

    observations[#observations + 1] = Messenger.observe( 'SWITCH_CHARACTERS', function( character )
        if not combatState:getFactions():getPlayerFaction():canSee( character:getTile() ) then
            return
        end
        camera:setTargetPosition( character:getTile():getX() * tw, character:getTile():getY() * th )
    end)

    observations[#observations + 1] = Messenger.observe( 'CHARACTER_MOVED', function( character )
        if not combatState:getFactions():getPlayerFaction():canSee( character:getTile() ) then
            return
        end
        camera:setTargetPosition( character:getTile():getX() * tw, character:getTile():getY() * th )
    end)

    return self
end

return CombatScreen