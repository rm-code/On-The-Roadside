local Pulser = require( 'src.util.Pulser' );
local MousePointer = require( 'src.ui.MousePointer' );
local Tileset = require( 'src.ui.Tileset' );
local Bresenham = require( 'lib.Bresenham' );
local ProjectilePath = require( 'src.items.weapons.ProjectilePath' );
local VectorMath = require( 'src.util.VectorMath' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local OverlayPainter = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local TILE_SIZE = require( 'src.constants.TileSize' );
local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local weaponCone = {};

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

    local function buildConeOutline( character, weapon )
        -- Get the tile at the mouse pointer's position.
        local cx, cy = MousePointer.getGridPosition();
        local target = game:getMap():getTileAt( cx, cy );

        -- Exit early if we don't have a valid target.
        if not target then
            return;
        end

        -- Fake the last bullet in the magazine so the maximum derivation
        -- represents that of a full weapon burst.
        local count;
        if weapon:getSubType() == WEAPON_TYPES.RANGED then
            count = weapon:getAttacks()
        end

        -- Calculate the derivation.
        local derivation = ProjectilePath.getMaximumDerivation( character, weapon, count );
        local origin = character:getTile();
        local px, py = origin:getPosition();
        local tx, ty = target:getPosition();

        do
            -- Callback function used in bresenham's algorithm.
            -- The status variable has to be declared here so it carries over
            -- between different tiles in bresenham's line algorithm.
            local status = 1;
            local function callback( sx, sy, counter )
                -- Get the tile at the rounded integer coordinates.
                local tile = game:getMap():getTileAt( math.floor( sx + 0.5 ), math.floor( sy + 0.5 ));
                -- If it is not a valid tile or the character's faction can't see the tile stop the
                -- ray. Always advance the ray if the tile is the character's tile.
                if not tile or not character:getFaction():canSee(tile) then
                    return false;
                elseif tile == origin then
                    return true;
                end

                -- Assign a status for this tile.
                -- 1 means the projectile can pass freely.
                -- 2 means the projectile might be blocked by a world object or character.
                -- 3 means the projectile will be blocked by a world object.
                -- 4 means the projectile can't reach this tile.
                local nstatus = 1;
                if tile:isOccupied() then
                    nstatus = 2;
                elseif tile:hasWorldObject() and ( tile:getWorldObject():isDestructible() or tile:getWorldObject():getSize() < 100 ) then
                    nstatus = 2;

                    -- World objects which are on a tile directly adjacent to the attacking
                    -- character will be ignored if they either are destructible or don't fill
                    -- the whole tile. Indestructible objects which cover the whole tile will
                    -- still block the shot.
                    if tile:isAdjacent( origin ) then
                        nstatus = 1;
                    end
                elseif tile:hasWorldObject() and not tile:getWorldObject():isDestructible() then
                    nstatus = 3;
                elseif counter > weapon:getRange() then
                    nstatus = 4;
                end

                -- The new status can't be better than the previously stored status.
                status = math.max( nstatus, status );

                -- Since multiple arrays might touch the same tile we use the maximum
                -- value stored for this tile.
                weaponCone[tile] = math.max( status, ( weaponCone[tile] or 1 ));
                return true;
            end

            -- Shoot multiple rays from the negative to the positive maxima for the
            -- weapon's "spread" angle.
            for angle = -derivation, derivation, 0.2 do
                local nx, ny = VectorMath.rotate( px, py, tx, ty, angle );
                status = 1;
                Bresenham.calculateLine( px, py, nx, ny, callback );
            end
        end
    end

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

        local weapon = character:getWeapon();
        if not weapon or weapon:getSubType() == WEAPON_TYPES.MELEE then
            return;
        end

        buildConeOutline( character, weapon );
        for tile, status in pairs( weaponCone ) do
            if status == 1 then
                love.graphics.setColor( COLORS.DB09[1], COLORS.DB09[2], COLORS.DB09[3], pulser:getPulse() );
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE );
            elseif status == 2 then
                love.graphics.setColor( COLORS.DB05[1], COLORS.DB05[2], COLORS.DB05[3], pulser:getPulse() );
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE );
            elseif status == 3 then
                love.graphics.setColor( COLORS.DB27[1], COLORS.DB27[2], COLORS.DB27[3], pulser:getPulse() );
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE );
            elseif status == 4 then
                love.graphics.setColor( COLORS.DB27[1], COLORS.DB27[2], COLORS.DB27[3], pulser:getPulse() );
                love.graphics.draw( Tileset.getTileset(), Tileset.getSprite( 89 ), tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE );
            end
            weaponCone[tile] = nil;
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
        if game:getState():instanceOf( 'ExecutionState' ) then
            return;
        end

        local mode = game:getState():getInputMode();
        if mode:instanceOf( 'MovementInput' ) and mode:hasPath() then
            local total = character:getActionPoints();
            local ap = total;
            mode:getPath():iterate( function( tile )
                ap = ap - tile:getMovementCost( character:getStance() );

                -- Draws the path overlay.
                love.graphics.setBlendMode( 'add' );
                local color = selectPathNodeColor( ap, total );
                love.graphics.setColor( color[1], color[2], color[3], pulser:getPulse() );
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE );
                love.graphics.setColor( COLORS.RESET );
                love.graphics.setBlendMode( 'alpha' );
            end);
        end
    end

    ---
    -- Draws a mouse cursor that snaps to the grid.
    --
    local function drawMouseCursor()
        if game:getState():instanceOf( 'ExecutionState' ) then
            return;
        end

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
