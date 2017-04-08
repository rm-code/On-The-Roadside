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
local MousePointer = require( 'src.ui.MousePointer' );
local ConeOverlay = require( 'src.ui.overlays.ConeOverlay' )
local PathOverlay = require( 'src.ui.overlays.PathOverlay' )
local ParticleLayer = require( 'src.ui.overlays.ParticleLayer' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local OverlayPainter = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates an new instance of the OverlayPainter class.
-- @tparam  Game           game The game object.
-- @treturn OverlayPainter      The new instance.
--
function OverlayPainter.new( game )
    local self = {};

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local particleLayer = ParticleLayer.new()
    local pulser = Pulser.new( 4, 80, 80 );
    local coneOverlay = ConeOverlay.new( game, pulser )
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
        local gx, gy = MousePointer.getGridPosition();
        local cx, cy = gx * tw, gy * th

        love.graphics.setColor( COLORS.DB00 );
        love.graphics.rectangle( 'fill', cx, cy, tw, th )

        if game:getState():getInputMode():instanceOf( 'MovementInput' ) then
            love.graphics.setColor( COLORS.DB18 );
            love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( 176 ), cx, cy )
        elseif game:getState():getInputMode():instanceOf( 'AttackInput' ) then
            love.graphics.setColor( COLORS.DB27 );
            love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( 11 ), cx, cy )
        elseif game:getState():getInputMode():instanceOf( 'InteractionInput' ) then
            love.graphics.setColor( COLORS.DB10 );
            love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( 30 ), cx, cy )
        end
        love.graphics.setColor( COLORS.RESET );
    end

    ---
    -- Draws all particles on the map that are visible to the player's faction.
    --
    local function drawParticles()
        for x, row in pairs( particleLayer:getParticleGrid() ) do
            for y, particle in pairs( row ) do
                if game:getFactions():getPlayerFaction():canSee( game:getMap():getTileAt( x, y )) then
                    love.graphics.setColor( particle:getColors() );
                    if particle:isAscii() then
                        love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( love.math.random( 1, 256 )), x * tw, y * th )
                    elseif particle:getSprite() then
                        love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( particle:getSprite() ), x * tw, y * th )
                    else
                        love.graphics.rectangle( 'fill', x * tw, y * th, tw, th )
                    end
                    love.graphics.setColor( COLORS.RESET );
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
        if not game:getState():instanceOf( 'ExecutionState' ) then
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
        and not game:getState():instanceOf( 'ExecutionState' ) then
            pathOverlay:draw()
            drawMouseCursor()
            coneOverlay:draw()
        end

        drawParticles()
    end

    return self;
end

return OverlayPainter;