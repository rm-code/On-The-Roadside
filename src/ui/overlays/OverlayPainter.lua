---
-- The OverlayPainter takes care of drawing overlays such as particles or
-- path indicators - Basically all things that are drawn on the map / a tile,
-- but not are not a part of the map.
--
-- @module OverlayPainter
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Pulser = require( 'src.util.Pulser' )
local AttackOverlay = require( 'src.ui.overlays.AttackOverlay' )
local PathOverlay = require( 'src.ui.overlays.PathOverlay' )
local ParticleLayer = require( 'src.ui.overlays.ParticleLayer' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local AttackInput = require( 'src.turnbased.helpers.AttackInput' )
local MovementInput = require( 'src.turnbased.helpers.MovementInput' )
local InteractionInput = require( 'src.turnbased.helpers.InteractionInput' )
local ExecutionState = require( 'src.turnbased.states.ExecutionState' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local OverlayPainter = Class( 'OverlayPainter' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Draws a mouse cursor that snaps to the grid.
--
local function drawMouseCursor( tileset, tw, th, camera, game )
    local gx, gy = camera:getMouseWorldGridPosition()
    local cx, cy = gx * tw, gy * th

    TexturePacks.setColor( 'sys_background' )
    love.graphics.rectangle( 'fill', cx, cy, tw, th )

    local id
    if game:getState():getInputMode():isInstanceOf( MovementInput ) then
        id = 'ui_mouse_pointer_movement'
    elseif game:getState():getInputMode():isInstanceOf( AttackInput ) then
        id = 'ui_mouse_pointer_attack'
    elseif game:getState():getInputMode():isInstanceOf( InteractionInput ) then
        id = 'ui_mouse_pointer_interact'
    end

    TexturePacks.setColor( id )
    love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( id ), cx, cy )
    TexturePacks.resetColor()
end

---
-- Draws all particles on the map that are visible to the player's faction.
--
local function drawParticles( tileset, tw, th, particleLayer, game )
    for x, row in pairs( particleLayer:getParticleGrid() ) do
        for y, particle in pairs( row ) do
            if game:getMap():getTileAt( x, y ):isSeenBy( FACTIONS.ALLIED ) then
                love.graphics.setColor( particle:getColors() )
                if particle:getSprite() then
                    love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( particle:getSprite() ), x * tw, y * th )
                else
                    love.graphics.rectangle( 'fill', x * tw, y * th, tw, th )
                end
                TexturePacks.resetColor()
            end
        end
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates an new instance of the OverlayPainter class.
-- @tparam Game          game   The game object.
-- @tparam CameraHandler camera A camera object used to move the map.
--
function OverlayPainter:initialize( game, camera )
    self.game = game
    self.camera = camera

    self.particleLayer = ParticleLayer( game:getProjectileManager()  )
    self.pulser = Pulser( 2, 0.2, 0.6 )
    self.attackOverlay = AttackOverlay( self.game, self.pulser, self.camera )
    self.pathOverlay = PathOverlay( self.game, self.pulser )

    self.tileset = TexturePacks.getTileset()
    self.tw, self.th = TexturePacks.getTileDimensions()
end

---
-- Updates the OverlayPainter.
-- @tparam number dt The time since the last frame.
--
function OverlayPainter:update( dt )
    if not self.game:getState():isInstanceOf( ExecutionState ) then
        self.attackOverlay:generate()
    end

    self.particleLayer:update( dt )
    self.pulser:update( dt )
end

---
-- Draws the OverlayPainter.
--
function OverlayPainter:draw()
    local character = self.game:getCurrentCharacter()
    if  not character:getFaction():isAIControlled()
    and not self.game:getState():isInstanceOf( ExecutionState ) then
        self.pathOverlay:draw()
        drawMouseCursor( self.tileset, self.tw, self.th, self.camera, self.game )
        self.attackOverlay:draw()
    end

    drawParticles( self.tileset, self.tw, self.th, self.particleLayer, self.game )
end

return OverlayPainter
