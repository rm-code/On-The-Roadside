---
-- The ConeOverlay module takes care of creating and drawing a cone which
-- represents a character's weapon spread.
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object         = require( 'src.Object' )
local MousePointer   = require( 'src.ui.MousePointer' )
local Bresenham      = require( 'lib.Bresenham' )
local ProjectilePath = require( 'src.items.weapons.ProjectilePath' )
local VectorMath     = require( 'src.util.VectorMath' )
local Tileset        = require( 'src.ui.Tileset' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ConeOverlay = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS       = require( 'src.constants.Colors' )
local TILE_SIZE    = require( 'src.constants.TileSize' )
local WEAPON_TYPES = require( 'src.constants.WeaponTypes' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function ConeOverlay.new( game, pulser )
    local self = Object.new():addInstance( 'ConeOverlay' )

    local map = game:getMap()
    local cone = {}

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:generate()
        local character = game:getCurrentCharacter()
        local weapon = character:getWeapon()
        if not game:getState():getInputMode():instanceOf( 'AttackInput' ) then
            return
        elseif not weapon or weapon:getSubType() == WEAPON_TYPES.MELEE then
            return
        end

        -- Get the tile at the mouse pointer's position.
        local cx, cy = MousePointer.getGridPosition()
        local target = map:getTileAt( cx, cy )

        -- Exit early if we don't have a valid target.
        if not target then
            return
        end

        -- Fake the last bullet in the magazine so the maximum derivation
        -- represents that of a full weapon burst.
        local count
        if weapon:getSubType() == WEAPON_TYPES.RANGED then
            count = weapon:getAttacks()
        end

        -- Calculate the derivation.
        local derivation = ProjectilePath.getMaximumDerivation( character, weapon, count )
        local origin = character:getTile()
        local px, py = origin:getPosition()
        local tx, ty = target:getPosition()

        do
            -- Callback function used in bresenham's algorithm.
            -- The status variable has to be declared here so it carries over
            -- between different tiles in bresenham's line algorithm.
            local status = 1
            local function callback( sx, sy, counter )
                -- Get the tile at the rounded integer coordinates.
                local tile = map:getTileAt( math.floor( sx + 0.5 ), math.floor( sy + 0.5 ))
                -- If it is not a valid tile or the character's faction can't see the tile stop the
                -- ray. Always advance the ray if the tile is the character's tile.
                if not tile or not character:getFaction():canSee(tile) then
                    return false
                elseif tile == origin then
                    return true
                end

                -- Assign a status for this tile.
                -- 1 means the projectile can pass freely.
                -- 2 means the projectile might be blocked by a world object or character.
                -- 3 means the projectile will be blocked by a world object.
                -- 4 means the projectile can't reach this tile.
                local nstatus = 1
                if tile:isOccupied() then
                    nstatus = 2
                elseif tile:hasWorldObject() and ( tile:getWorldObject():isDestructible() or tile:getWorldObject():getHeight() < 100 ) then
                    nstatus = 2

                    -- World objects which are on a tile directly adjacent to the attacking
                    -- character will be ignored if they either are destructible or don't fill
                    -- the whole tile. Indestructible objects which cover the whole tile will
                    -- still block the shot.
                    if tile:isAdjacent( origin ) then
                        nstatus = 1
                    end
                elseif tile:hasWorldObject() and not tile:getWorldObject():isDestructible() then
                    nstatus = 3
                elseif counter > weapon:getRange() then
                    nstatus = 4
                end

                -- The new status can't be better than the previously stored status.
                status = math.max( nstatus, status )

                -- Since multiple arrays might touch the same tile we use the maximum
                -- value stored for this tile.
                cone[tile] = math.max( status, ( cone[tile] or 1 ))
                return true
            end

            -- Shoot multiple rays from the negative to the positive maxima for the
            -- weapon's "spread" angle.
            for angle = -derivation, derivation, 0.2 do
                local nx, ny = VectorMath.rotate( px, py, tx, ty, angle )
                status = 1
                Bresenham.line( px, py, nx, ny, callback )
            end
        end
    end

    function self:draw()
        for tile, status in pairs( cone ) do
            if status == 1 then
                love.graphics.setColor( COLORS.DB09[1], COLORS.DB09[2], COLORS.DB09[3], pulser:getPulse() )
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE )
            elseif status == 2 then
                love.graphics.setColor( COLORS.DB05[1], COLORS.DB05[2], COLORS.DB05[3], pulser:getPulse() )
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE )
            elseif status == 3 then
                love.graphics.setColor( COLORS.DB27[1], COLORS.DB27[2], COLORS.DB27[3], pulser:getPulse() )
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE )
            elseif status == 4 then
                love.graphics.setColor( COLORS.DB27[1], COLORS.DB27[2], COLORS.DB27[3], pulser:getPulse() )
                love.graphics.draw( Tileset.getTileset(), Tileset.getSprite( 89 ), tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE )
            end
            cone[tile] = nil
        end
    end

    return self
end

return ConeOverlay
