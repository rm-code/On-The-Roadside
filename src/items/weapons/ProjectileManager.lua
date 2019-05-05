---
-- @module ProjectileManager
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Observable = require( 'src.util.Observable' )
local Util = require( 'src.util.Util' )
local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ProjectileManager = Observable:subclass( 'ProjectileManager' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DAMAGE_TYPES = require( 'src.constants.DAMAGE_TYPES' )

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Removes a projectile from the world and hits a tile with the projectile damage.
-- @tparam Tile       tile       The tile to hit.
-- @tparam Projectile projectile The projectile to remove.
--
local function hitTile( self, tile, projectile )
    if projectile:getDamageType() == DAMAGE_TYPES.EXPLOSIVE then
        local tiles = Util.getTilesInCircle( self.map, tile, projectile:getWeapon():getAreaOfEffectRadius() )
        for i = 1, #tiles do
            tiles[i]:hit( projectile:getDamage(), projectile:getDamageType() )
        end
    end

    tile:hit( projectile:getDamage(), projectile:getDamageType() )
end

---
-- Checks if the projectile has hit any characters or worldobjects.
-- @tparam ProjectileQueue queue      The ProjectileQueue to process.
-- @tparam number          index      The id of the projectile which will be used for removing it.
-- @tparam Projectile      projectile The projectile to handle.
-- @tparam Tile            tile       The tile to check.
-- @tparam Character       character  The character who fired this projectile.
--
local function checkForHits( self, queue, index, projectile, tile )
    -- Stop movement and remove the projectile if it has reached the map border.
    if not tile then
        queue:removeProjectile( index )
        return
    end

    if tile:hasCharacter() then
        Log.debug( 'Projectile hit character', 'ProjectileManager' )
        hitTile( self, tile, projectile )
        queue:removeProjectile( index )
        return true
    end

    -- Remove the projectile if it hits a world object on the way to its target.
    if tile:hasWorldObject() and tile:getWorldObject():isFullCover() then
        Log.debug( 'Projectile hits world object', 'ProjectileManager' )
        hitTile( self, tile, projectile )
        queue:removeProjectile( index )
        return
    end

    -- Remove the projectile if it hits the target of its attack.
    if projectile:hasReachedTarget() then
        Log.debug( 'Projectile reached target tile', 'ProjectileManager' )
        hitTile( self, tile, projectile )
        queue:removeProjectile( index )
        return
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Initialise the ProjectileManager.
-- @tparam Map map The game's map.
--
function ProjectileManager:initialize( map )
    Observable.initialize( self )

    self.map = map
end

---
-- Updates the ProjectileManager which handles a ProjectileQueue for spawning
-- projectiles and the interaction of each projectile with the game world.
-- @tparam number dt The time since the last frame.
--
function ProjectileManager:update( dt )
    if not self.queue then
        return
    end

    -- Updates the time of the projectile queue which handles spawning of
    -- new projectiles.
    self.queue:update( dt )

    -- Update the projectiles currently in the game world.
    for i, projectile in pairs( self.queue:getProjectiles() ) do
        projectile:update( dt )

        -- If the projectile has moved notify the world and check if it has
        -- hit anything.
        if projectile:hasMoved( self.map ) then
            projectile:updateTile( self.map )
            self:publish( 'PROJECTILE_MOVED', projectile )

            checkForHits( self, self.queue, i, projectile, projectile:getTile() )
        end
    end
end

---
-- Registers a new projectile queue.
-- @tparam ProjectileQueue queue The ProjectileQueue to process.
--
function ProjectileManager:register( queue )
    self.queue = queue
end

---
-- Returns true if there isn't a queue or if the current queue has been processed.
-- @treturn boolean True if the projectile manager has processed the queue.
--
function ProjectileManager:isDone()
    if not self.queue then
        return true
    end
    return self.queue:isDone()
end

return ProjectileManager
