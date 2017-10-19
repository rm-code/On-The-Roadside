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
local TexturePacks   = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ConeOverlay = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function ConeOverlay.new( game, pulser )
    local self = Object.new():addInstance( 'ConeOverlay' )

    local map = game:getMap()
    local cone = {}
    local tileset = TexturePacks.getTileset()
    local tw, th = tileset:getTileDimensions()

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Determine the height falloff for the cone overlay.
    -- @tparam  Tile   origin The starting tile.
    -- @tparam  Tile   target The target tile.
    -- @tparam  number steps  The distance to the target.
    -- @treturn number        The calculated falloff value.
    --
    local function calculateFalloff( origin, target, steps )
        local oheight = origin:getHeight()
        local theight = target:getHeight()

        local delta = oheight - theight
        return delta / steps
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:generate()
        -- Exit early if we aren't in the attack input mode.
        if not game:getState():getInputMode():instanceOf( 'AttackInput' ) then
            return
        end

        -- Exit early if the character doesn't have a weapon or the weapon is
        -- of type melee.
        local weapon = game:getCurrentCharacter():getWeapon()
        if not weapon or weapon:getSubType() == WEAPON_TYPES.MELEE then
            return
        end

        -- Get the tile at the mouse pointer's position.
        local cx, cy = MousePointer.getGridPosition()
        local target = map:getTileAt( cx, cy )

        -- Exit early if we don't have a valid target.
        if not target then
            return
        end

        -- Use the number of attacks to predict the derivation for burst attacks correctly.
        local count = weapon:getSubType() == WEAPON_TYPES.RANGED and weapon:getAttacks() or 1;

        -- Calculate the derivation.
        local character = game:getCurrentCharacter()
        local derivation = ProjectilePath.getMaximumDerivation( character, weapon, count )
        local origin = character:getTile()
        local px, py = origin:getPosition()
        local tx, ty = target:getPosition()

        -- Calculate the height falloff for the cone.
        local _, steps = Bresenham.line( px, py, tx, ty )
        local falloff  = calculateFalloff( origin, target, steps )
        local startHeight = origin:getHeight()

        do
            -- Callback function used in bresenham's algorithm.
            -- The status variable has to be declared here so it carries over
            -- between different tiles in bresenham's line algorithm.
            local status = 1
            local function callback( sx, sy, counter )
                -- Get the tile at the rounded integer coordinates.
                local tile = map:getTileAt( math.floor( sx + 0.5 ), math.floor( sy + 0.5 ))

                -- Stop early if the tile is not valid.
                if not tile then
                    return false
                end

                -- Stop early if the target is out of range.
                if counter > weapon:getRange() then
                    return false
                end

                -- Always advance the ray on the original tile.
                if tile == origin then
                    return true
                end

                -- Calculate the height of the ray.
                local height = startHeight - (counter+1) * falloff

                -- Assign a status for this tile.
                -- 1 means the projectile can pass freely.
                -- 2 means the projectile might be blocked by a world object or character.
                -- 3 means the projectile will be blocked by a world object.
                local nstatus = 1
                if tile:isOccupied() or not character:canSee( tile ) then
                    nstatus = 2
                elseif tile:hasWorldObject() and height <= tile:getWorldObject():getHeight() then
                    -- Indestructible worldobjects block the shot.
                    if not tile:getWorldObject():isDestructible() then
                        nstatus = 3
                    else
                        nstatus = 2
                    end
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
            local color
            if status == 1 then
                color = TexturePacks.getColor( 'ui_shot_valid' )
            elseif status == 2 then
                color = TexturePacks.getColor( 'ui_shot_potentially_blocked' )
            elseif status == 3 then
                color = TexturePacks.getColor( 'ui_shot_blocked' )
            end
            love.graphics.setColor( color[1], color[2], color[3], pulser:getPulse() )
            love.graphics.rectangle( 'fill', tile:getX() * tw, tile:getY() * th, tw, th )
            cone[tile] = nil
        end
        TexturePacks.resetColor()
    end

    return self
end

return ConeOverlay
