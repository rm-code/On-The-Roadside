local Bresenham = require( 'lib.Bresenham' );
local Messenger = require( 'src.Messenger' );
local Util = require( 'src.util.Util' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ExplosionManager = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DAMAGE_TYPES = require( 'src.constants.DAMAGE_TYPES' );

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local map;
local explosionLayout;
local explosionIndex = 1;
local timer = 0;
local delay = 0.02;

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Determines all tiles which are hit by the explosion.
-- @param source (Tile)   The origin of the explosion.
-- @param list   (table)  A sequence containing all tiles in the explosion's radius.
-- @param radius (radius) The maximum radius of the explosion.
-- @return       (table)  A table containing sub-tables for each line.
--
local function generateExplosionMap( source, list, radius )
    local sx, sy = source:getPosition();
    local queues = {};

    -- Iterate over all tiles in the list. Get all tiles between the source of
    -- the explosion and each tile in the list and store them in a table.
    for _, tile in ipairs( list ) do
        local queue = {};

        -- Randomize the radius to prevent all target tiles to be hit covered. This
        -- is done to prevent a perfectly circular explosion.
        local length = love.math.random( radius );

        if tile ~= source then
            local tx, ty = tile:getPosition();

            -- Cast a ray from the source of the explosion to the target tile.
            Bresenham.line( sx, sy, tx, ty, function( cx, cy, count )
                local target = map:getTileAt( cx, cy );

                -- Stop at impassable world objects that cover the whole tile.
                if target:hasWorldObject()
                and not target:getWorldObject():isDestructible()
                and target:getWorldObject():getSize() == 100 then
                    return false;
                end

                -- Stop at the maximum range of the explosion.
                if length == count then
                    return false;
                end

                -- Store the target tile.
                queue[#queue + 1] = target;
                return true;
            end)
        end

        -- Store the table for this specific line.
        queues[#queues + 1] = queue;
    end

    return queues;
end

---
-- Determines the different steps for the spreading of the explosion. Imagine
-- this as onion layers starting at the center of the explosion and advancing
-- tile by tile until the maximum radius is reached.
-- @param queues (table)  The table layout containing all hit tiles.
-- @param damage (number) The explosion's base damage.
-- @param radius (number) The radius of the explosion.
-- @return       (table)  A table containing subtables for each step of the explosion.
--
local function generateExplosionSteps( queues, damage, radius )
    local layout = {};
    for i = 1, radius do
        local steps = {}
        for _, queue in ipairs( queues ) do
            local tile = queue[i];
            if tile then
                steps[tile] = damage;
            end
        end
        layout[i] = steps;
    end
    return layout;
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Updates the current explosion.
--
function ExplosionManager.update( dt )
    if not explosionLayout then
        return;
    end
    timer = timer - dt;

    -- If the last step of the explosion has been reached delete the current
    -- explosion layout.
    if not explosionLayout[explosionIndex] then
        explosionLayout = nil;
        return;
    end

    -- Advances the explosion and publishes a message about it.
    if explosionLayout and timer <= 0 then
        -- Notify anyone who cares.
        Messenger.publish( 'EXPLOSION', explosionLayout[explosionIndex] );
        -- Damage the hit tiles. The damage is the base damage minus a random
        -- value in the range of [1, 10% of damage] multiplied by the distance
        -- to the source of the explosion.
        for tile, damage in pairs( explosionLayout[explosionIndex] ) do
            tile:hit( damage - love.math.random( damage * 0.1 ) * explosionIndex, DAMAGE_TYPES.EXPLOSIVE );
        end
        -- Advance the step index.
        explosionIndex = explosionIndex + 1;
        timer = delay;
    end
end

---
-- Initialises the ExplosionManager.
-- @param nmap (Map) The map object.
--
function ExplosionManager.init( nmap )
    map = nmap;
end

---
-- Registers and creates a new explosion.
-- @param source (Tile)   The explosion's source.
-- @param damage (number) The explosion's base damage.
-- @param radius (number) The explosion's radius.
--
function ExplosionManager.register( source, damage, radius )
    local list = Util.getTilesInCircle( map, source, radius );
    local queues = generateExplosionMap( source, list, radius );
    explosionLayout = generateExplosionSteps( queues, damage, radius );
    explosionIndex = 1;
end

---
-- Remove any saved state.
--
function ExplosionManager.clear()
    map = nil;
    explosionLayout = nil;
    explosionIndex = 1;
    timer = 0;
    delay = 0.02;
end

---
-- Returns true if all explosions have been handled.
-- @return (boolean) False if an explosion is active.
--
function ExplosionManager.isDone()
    if explosionLayout then
        return false;
    end
    return true;
end

return ExplosionManager;
