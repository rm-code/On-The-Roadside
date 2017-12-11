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

local Pulser = require( 'src.util.Pulser' );
local ConeOverlay = require( 'src.ui.overlays.ConeOverlay' )
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

local OverlayPainter = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates an new instance of the OverlayPainter class.
-- @tparam  Game           game   The game object.
-- @tparam  CameraHandler  camera A camera object used to move the map.
-- @treturn OverlayPainter        The new instance.
--
function OverlayPainter.new( game, camera )
    local self = {};

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local particleLayer = ParticleLayer.new()
    local pulser = Pulser.new( 4, 80, 80 );
    local coneOverlay = ConeOverlay.new( game, pulser, camera )
    local pathOverlay = PathOverlay.new( game, pulser )
    local tileset = TexturePacks.getTileset()
    local tw, th = TexturePacks.getTileDimensions()

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Draws a mouse cursor that snaps to the grid.
    --
    local function drawMouseCursor()
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
    local function drawParticles()
        for x, row in pairs( particleLayer:getParticleGrid() ) do
            for y, particle in pairs( row ) do
                if game:getFactions():getPlayerFaction():canSee( game:getMap():getTileAt( x, y )) then
                    love.graphics.setColor( particle:getColors() );
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
    -- Updates the OverlayPainter.
    -- @tparam number dt The time since the last frame.
    --
    function self:update( dt )
        if not game:getState():isInstanceOf( ExecutionState ) then
            coneOverlay:generate()
        end

        particleLayer:update( dt )
        pulser:update( dt )
    end

    ---
    -- Draws the OverlayPainter.
    --
    function self:draw()
        local character = game:getCurrentCharacter()
        if  not character:getFaction():isAIControlled()
        and not game:getState():isInstanceOf( ExecutionState ) then
            pathOverlay:draw()
            drawMouseCursor()
            coneOverlay:draw()
        end

        drawParticles()
    end

    return self;
end

return OverlayPainter;
