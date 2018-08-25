---
-- @module CombatScreen
--

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )
local CombatState = require( 'src.CombatState' )
local MapPainter = require( 'src.ui.MapPainter' )
local Camera = require( 'src.ui.Camera' )
local UserInterface = require( 'src.ui.elements.UserInterface' )
local OverlayPainter = require( 'src.ui.overlays.OverlayPainter' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Settings = require( 'src.Settings' )
local SoundManager = require( 'src.SoundManager' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CombatScreen = Screen:subclass( 'CombatScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function CombatScreen:initialize( playerFaction, savegame )
    love.mouse.setVisible( true )

    self.combatState = CombatState( playerFaction, savegame )

    self.mapPainter = MapPainter( self.combatState:getMap() )

    local tw, th = TexturePacks.getTileDimensions()
    local mw, mh = self.combatState:getMap():getDimensions()
    self.camera = Camera( mw, mh, tw, th )

    self.userInterface = UserInterface( self.combatState, self.camera )
    self.overlayPainter = OverlayPainter( self.combatState, self.camera )

    self.combatState:getMap():observe( self )
end

function CombatScreen:receive( event, ... )
    if event == 'CHARACTER_MOVED' then
        local tile = ...
        if not tile:isSeenBy( FACTIONS.ALLIED ) then
            return
        end
        local tw, th = TexturePacks.getTileDimensions()
        self.camera:setTargetPosition( tile:getX() * tw, tile:getY() * th )
        return
    end
end


function CombatScreen:draw()
    self.camera:attach()
    self.mapPainter:draw()
    self.overlayPainter:draw()
    self.camera:detach()
    self.userInterface:draw()
end

function CombatScreen:update( dt )
    if self:isActive() then
        self.camera:update( dt )
    end

    self.combatState:update( dt )
    self.mapPainter:setActiveFaction( self.combatState:getPlayerFaction() )
    self.mapPainter:update( dt )
    self.overlayPainter:update( dt )
    self.userInterface:update( dt )
end

function CombatScreen:keypressed( key, scancode, isrepeat )
    if scancode == 'f' then
        love.window.setFullscreen( not love.window.getFullscreen() )
    end
    if scancode == 'f1' then
        self.userInterface:toggleDebugInfo()
    end
    if scancode == 'escape' then
        ScreenManager.push( 'ingamemenu', self.combatState )
    end

    self.combatState:keypressed( key, scancode, isrepeat )
    self.camera:input( Settings.mapInput( Settings.INPUTLAYOUTS.COMBAT, scancode ), true )
end

function CombatScreen:keyreleased( _, scancode )
    self.camera:input( Settings.mapInput( Settings.INPUTLAYOUTS.COMBAT, scancode ), false )
end

function CombatScreen:mousepressed( _, _, button )
    local mx, my = self.camera:getMouseWorldGridPosition()
    self.combatState:mousepressed( mx, my, button )
end

function CombatScreen:mousefocus( f )
    if f then
        self.camera:unlock()
    else
        self.camera:lock()
    end
end

function CombatScreen:close()
    self.combatState:close()
end

function CombatScreen:resize( _, _ )
    self.userInterface:resize()
end

return CombatScreen
