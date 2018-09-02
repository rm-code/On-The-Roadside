---
-- @module ExplosionManager
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Bresenham = require( 'lib.Bresenham' )
local SoundManager = require( 'src.SoundManager' )
local Util = require( 'src.util.Util' )
local Observable = require( 'src.util.Observable' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ExplosionManager = Observable:subclass( 'ExplosionManager' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DAMAGE_TYPES = require( 'src.constants.DAMAGE_TYPES' )

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Determines all tiles which are hit by the explosion.
-- @tparam  Tile   source The origin of the explosion.
-- @tparam  table  list   A sequence containing all tiles in the explosion's radius.
-- @tparam  number radius The maximum radius of the explosion.
-- @treturn table         A table containing sub-tables for each line.
--
local function generateExplosionMap( map, source, list, radius )
    local sx, sy = source:getPosition()
    local queues = {}

    -- Iterate over all tiles in the list. Get all tiles between the source of
    -- the explosion and each tile in the list and store them in a table.
    for _, tile in ipairs( list ) do
        local queue = {}

        -- Randomize the radius to prevent all target tiles to be hit covered. This
        -- is done to prevent a perfectly circular explosion.
        local length = love.math.random( radius )

        if tile ~= source then
            local tx, ty = tile:getPosition()

            -- Cast a ray from the source of the explosion to the target tile.
            Bresenham.line( sx, sy, tx, ty, function( cx, cy, count )
                local target = map:getTileAt( cx, cy )

                -- Stop at impassable world objects that cover the whole tile.
                if target:hasWorldObject()
                and not target:getWorldObject():isDestructible()
                and target:getWorldObject():getHeight() == 100 then
                    return false
                end

                -- Stop at the maximum range of the explosion.
                if length == count then
                    return false
                end

                -- Store the target tile.
                queue[#queue + 1] = target
                return true
            end)
        end

        -- Store the table for this specific line.
        queues[#queues + 1] = queue
    end

    return queues
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
    local layout = {}
    for i = 1, radius do
        local steps = {}
        for _, queue in ipairs( queues ) do
            local tile = queue[i]
            if tile then
                steps[tile] = damage
            end
        end
        layout[i] = steps
    end
    return layout
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initialises the ExplosionManager.
-- @tparam Map map The map object.
--
function ExplosionManager:initialize( map )
    Observable.initialize( self )

    self.map = map
    self.timer = 0
    self.delay = 0.02
end

---
-- Updates the current explosion.
--
function ExplosionManager:update( dt )
    if not self.explosionLayout then
        return
    end
    self.timer = self.timer - dt

    -- If the last step of the explosion has been reached delete the current
    -- explosion layout.
    if not self.explosionLayout[self.explosionIndex] then
        self.explosionLayout = nil
        return
    end

    -- Advances the explosion and publishes a message about it.
    if self.explosionLayout and self.timer <= 0 then
        -- Notify anyone who cares.
        self:publish( 'EXPLOSION', self.explosionLayout[self.explosionIndex] )
        SoundManager.play( 'sound_explode')

        -- Damage the hit tiles.
        for tile, damage in pairs( self.explosionLayout[self.explosionIndex] ) do
            tile:hit( damage, DAMAGE_TYPES.EXPLOSIVE )
        end
        -- Advance the step index.
        self.explosionIndex = self.explosionIndex + 1
        self.timer = self.delay
    end
end

---
-- Receives events.
-- @tparam string  event The received event.
-- @tparam varargs ...   Variable arguments.
--
function ExplosionManager:receive( event, ... )
    if event == 'CREATE_EXPLOSION' then
        local source, damage, radius = ...

        local list = Util.getTilesInCircle( self.map, source, radius )
        local queues = generateExplosionMap( self.map, source, list, radius )
        self.explosionLayout = generateExplosionSteps( queues, damage, radius )
        self.explosionIndex = 1
    end
end

---
-- Returns true if all explosions have been handled.
-- @treturn boolean False if an explosion is active.
--
function ExplosionManager:isDone()
    if self.explosionLayout then
        return false
    end
    return true
end

return ExplosionManager
