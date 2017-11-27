---
-- @module CombatScreen
--

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'lib.screenmanager.Screen' )
local CombatState = require( 'src.CombatState' )
local MapPainter = require( 'src.ui.MapPainter' )
local CameraHandler = require('src.ui.CameraHandler')
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

    function self:init( playerFaction, savegame )
        love.mouse.setVisible( true )

        combatState = CombatState.new()
        combatState:init( playerFaction, savegame )

        mapPainter = MapPainter( combatState:getMap() )

        local mw, mh = combatState:getMap():getDimensions()
        camera = CameraHandler.new( mw, mh, tw, th )

        userInterface = UserInterface.new( combatState, camera )

        overlayPainter = OverlayPainter.new( combatState, camera )
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
        mapPainter:setActiveFaction( combatState:getPlayerFaction() )
        mapPainter:update( dt )
        overlayPainter:update( dt )
        userInterface:update( dt )
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
        local mx, my = camera:getMouseWorldGridPosition()
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
