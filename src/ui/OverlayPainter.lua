local Pulser = require( 'src.util.Pulser' );
local MousePointer = require( 'src.ui.MousePointer' );
local Tileset = require( 'src.ui.Tileset' );
local Bresenham = require( 'lib.Bresenham' );

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
    love.mouse.setVisible( false );

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Draws a line from the character to a selected target.
    -- @param character (Character) The character to draw the LOS for.
    --
    local function drawLineOfSight( character )
        if game:getState():instanceOf( 'ExecutionState' ) then
            return;
        end

        if game:getState():instanceOf( 'PlanningState' ) and not game:getState():getInputMode():instanceOf( 'AttackInput' ) then
            return;
        end

        local weapon = character:getInventory():getWeapon();
        if not weapon or weapon:getWeaponType() == 'Melee' or weapon:getWeaponType() == 'Grenade' then
            return;
        end

        local ox, oy = character:getTile():getPosition();
        local map = game:getMap();

        local cx, cy = MousePointer.getGridPosition();
        local target = map:getTileAt( cx, cy );

        if target then
            local tx, ty = target:getPosition();

            Bresenham.calculateLine( ox, oy, tx, ty, function( sx, sy, count )
                love.graphics.setBlendMode( 'add' );

                local tile = map:getTileAt( sx, sy );
                local visible = character:getFaction():canSee( tile );

                if not visible
                        or weapon:getMagazine():isEmpty()
                        or character:getActionPoints() < weapon:getAttackCost()
                        or count > weapon:getRange() then
                    love.graphics.setColor( COLORS.DB27[1], COLORS.DB27[2], COLORS.DB27[3], pulser:getPulse() );
                elseif tile:hasWorldObject() or tile:isOccupied() then
                    love.graphics.setColor( COLORS.DB05[1], COLORS.DB05[2], COLORS.DB05[3], pulser:getPulse() );
                else
                    love.graphics.setColor( COLORS.DB09[1], COLORS.DB09[2], COLORS.DB09[3], pulser:getPulse() );
                end

                if count > weapon:getRange() then
                    love.graphics.draw( Tileset.getTileset(), Tileset.getSprite( 89 ), tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE );
                else
                    love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE );
                end

                -- Reset drawing state.
                love.graphics.setColor( 255, 255, 255, 255 );
                love.graphics.setBlendMode( 'alpha' );
                return true;
            end)
        end
    end

    ---
    -- Selects a color for the node in a path based on the distance to the
    -- target and the remaining action points the character has.
    -- @param value (number) The cost of the node.
    -- @param total (number) The total number of nodes in the path.
    --
    local function selectPathNodeColor( value, total )
        local fraction = value / total;
        if fraction < 0 then
            return COLORS.DB27;
        elseif fraction <= 0.2 then
            return COLORS.DB05;
        elseif fraction <= 0.6 then
            return COLORS.DB08;
        elseif fraction <= 1.0 then
            return COLORS.DB09;
        end
    end

    ---
    -- Draws a path for this character.
    -- @param character (Character) The character to draw the path for.
    --
    local function drawPath( character )
        if character:getActionPoints() > 0 and #character:getActions() ~= 0 then
            local total = character:getActionPoints();
            local ap = total;

            for _, action in ipairs( character:getActions() ) do
                ap = ap - action:getCost();

                -- Clears the tile.
                local tile = action:getTarget();

                -- Draws the path overlay.
                love.graphics.setBlendMode( 'add' );
                local color = selectPathNodeColor( ap, character:getMaxActionPoints() );
                love.graphics.setColor( color[1], color[2], color[3], pulser:getPulse() );
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE );
                love.graphics.setColor( 255, 255, 255, 255 );
                love.graphics.setBlendMode( 'alpha' );
            end
        end
    end

    ---
    -- Draws a mouse cursor that snaps to the grid.
    --
    local function drawMouseCursor()
        if game:getState():instanceOf( 'ExecutionState' ) then
            return;
        end

        local mx, my = MousePointer.getWorldPosition();
        local cx, cy = math.floor( mx / TILE_SIZE ) * TILE_SIZE, math.floor( my / TILE_SIZE ) * TILE_SIZE;

        love.graphics.setColor( 0, 0, 0 );
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
        love.graphics.setColor( 255, 255, 255, 255 );
    end

    local function drawParticles()
        for x, row in pairs( particleLayer:getParticleGrid() ) do
            for y, particle in pairs( row ) do
                if game:getFactions():getPlayerFaction():canSee( game:getMap():getTileAt( x, y )) then
                    love.graphics.setColor( particle:getColors() );
                    if particle:isAscii() then
                        love.graphics.draw( Tileset.getTileset(), Tileset.getSprite( love.math.random( 1, 256 )), x * TILE_SIZE, y * TILE_SIZE );
                    else
                        love.graphics.rectangle( 'fill', x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE );
                    end
                    love.graphics.setColor( 255, 255, 255, 255 );
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:draw()
        local character = game:getFactions():getFaction():getCurrentCharacter();
        if not character:getFaction():isAIControlled() then
            drawLineOfSight( character );
            drawPath( character );
            drawMouseCursor();
        end
        drawParticles();
    end

    function self:update( dt )
        particleLayer:update( dt );
        pulser:update( dt );
    end

    return self;
end

return OverlayPainter;
