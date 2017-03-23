local Pulser = require( 'src.util.Pulser' );
local MousePointer = require( 'src.ui.MousePointer' );
local Tileset = require( 'src.ui.Tileset' );
local ConeOverlay = require( 'src.ui.overlays.ConeOverlay' )
local PathOverlay = require( 'src.ui.overlays.PathOverlay' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local OverlayPainter = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates an new instance of the OverlayPainter class.
-- @param game          (Game)           The game object.
-- @param particleLayer (ParticleLayer)  The layer used for drawing particles.
-- @return              (OverlayPainter) The new instance.
--
function OverlayPainter.new( game, particleLayer )
    local self = {};

    local pulser = Pulser.new( 4, 80, 80 );
    local coneOverlay = ConeOverlay.new( game, pulser )
    local pathOverlay = PathOverlay.new( game, pulser )
    love.mouse.setVisible( false );

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Draws a mouse cursor that snaps to the grid.
    --
    local function drawMouseCursor()
        local gx, gy = MousePointer.getGridPosition();
        local cx, cy = gx * TILE_SIZE, gy * TILE_SIZE;

        love.graphics.setColor( COLORS.DB00 );
        love.graphics.rectangle( 'fill', cx, cy, TILE_SIZE, TILE_SIZE );

        if game:getState():getInputMode():instanceOf( 'MovementInput' ) then
            love.graphics.setColor( COLORS.DB18 );
            love.graphics.draw( Tileset.getTileset(), Tileset.getSprite( 176 ), cx, cy );
        elseif game:getState():getInputMode():instanceOf( 'AttackInput' ) then
            love.graphics.setColor( COLORS.DB27 );
            love.graphics.draw( Tileset.getTileset(), Tileset.getSprite( 11 ), cx, cy );
        elseif game:getState():getInputMode():instanceOf( 'InteractionInput' ) then
            love.graphics.setColor( COLORS.DB10 );
            love.graphics.draw( Tileset.getTileset(), Tileset.getSprite( 30 ), cx, cy );
        end
        love.graphics.setColor( COLORS.RESET );
    end

    local function drawParticles()
        for x, row in pairs( particleLayer:getParticleGrid() ) do
            for y, particle in pairs( row ) do
                if game:getFactions():getPlayerFaction():canSee( game:getMap():getTileAt( x, y )) then
                    love.graphics.setColor( particle:getColors() );
                    if particle:isAscii() then
                        love.graphics.draw( Tileset.getTileset(), Tileset.getSprite( love.math.random( 1, 256 )), x * TILE_SIZE, y * TILE_SIZE );
                    elseif particle:getSprite() then
                        love.graphics.draw( Tileset.getTileset(), Tileset.getSprite( particle:getSprite() ), x * TILE_SIZE, y * TILE_SIZE );
                    else
                        love.graphics.rectangle( 'fill', x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE );
                    end
                    love.graphics.setColor( COLORS.RESET );
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update( dt )
        if not game:getState():instanceOf( 'ExecutionState' ) then
            coneOverlay:generate()
        end

        particleLayer:update( dt )
        pulser:update( dt )
    end

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
