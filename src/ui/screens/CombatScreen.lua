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
-- Local Methods
-- ------------------------------------------------

---
-- Centers the camera on the currently selected character.
-- @tparam Character character The character to center the camera on.
-- @tparam Camera    camera    The camera to center.
-- @tparam number    tw        The tile width.
-- @tparam number    th        The tile height.
--
local function centerCamera( character, camera, tw, th )
    camera:setTargetPosition( character:getX() * tw, character:getY() * th )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function CombatScreen:initialize( savegame )
    love.mouse.setVisible( true )

    self.combatState = CombatState( savegame )

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

    if event == 'CHARACTER_SELECTED' then
        local tile = ...
        if not tile:isSeenBy( FACTIONS.ALLIED ) then
            return
        end
        local tw, th = TexturePacks.getTileDimensions()
        self.camera:setTargetPosition( tile:getX() * tw, tile:getY() * th )
        SoundManager.play( 'sound_select' )
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

    if Settings.mapInput( Settings.INPUTLAYOUTS.COMBAT, scancode ) == 'center_camera' then
        centerCamera( self.combatState:getPlayerFaction():getCurrentCharacter(), self.camera, TexturePacks.getTileDimensions() )
        return
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
    self.camera:lock( f )
end

function CombatScreen:resize( _, _ )
    self.userInterface:resize()
end

return CombatScreen
