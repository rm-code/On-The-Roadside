local Log = require( 'src.util.Log' );
local Messenger = require( 'src.Messenger' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local Util = require( 'src.util.Util' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ProjectileManager = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DAMAGE_TYPES = require( 'src.constants.DAMAGE_TYPES' );

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local queue;
local map;

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Removes a projectile from the world and hits a tile with the projectile
-- damage.
-- @param index      (number)     The index of the projectile to remove.
-- @param remove     (boolean)    Wether to remove the projectile or not.
-- @param tile       (Tile)       The tile to hit.
-- @param projectile (Projectile) The projectile to remove.
--
local function hitTile( index, remove, tile, projectile )
    if remove then
        queue:removeProjectile( index );
    end

    if projectile:getDamageType() == DAMAGE_TYPES.EXPLOSIVE then
        ExplosionManager.register( tile, projectile:getDamage(), projectile:getEffects():getBlastRadius() );
        return;
    end

    tile:hit( projectile:getDamage() * ( projectile:getEnergy() / 100 ), projectile:getDamageType() );
end

---
-- Reduces the energy of the projectile with slightly randomized values.
-- @params energy    (number) The current energy.
-- @params reduction (number) The reduction that should be applied.
-- @return           (number) The modified energy value.
--
local function reduceProjectileEnergy( energy, reduction )
    reduction = love.math.random( reduction - 10, reduction + 10 );
    reduction = Util.clamp( 1, reduction, 100 )
    return energy - reduction;
end

---
--
local function hitCharacter( index, remove, tile, projectile )
    Log.debug( 'Projectile hit character', 'ProjectileManager' )
    hitTile( index, remove, tile, projectile )
end

---
-- Handles how to proceed if the projectile hits a world object.
-- @param index       (number)      The id of the projectile which will be used for removing it.
-- @param projectile  (Projectile)  The projectile to handle.
-- @param tile        (Tile)        The tile to check.
-- @param worldObject (WorldObject) The world object to check.
--
local function hitWorldObject( index, projectile, tile, worldObject )
    if projectile:getHeight() > worldObject:getHeight() then
        Log.debug( 'Projectile flies over world object', 'ProjectileManager' )
        return
    end

    -- Remove projectiles when they hit indestructible world objects.
    if not worldObject:isDestructible() then
        Log.debug( 'Projectile hits indestructible world object', 'ProjectileManager' )

        -- Explosive projectiles explode on the previous tile once they hit an
        -- indestructible world object. This needs to be done to make sure explosions
        -- occur on the right side of the world object.
        if projectile:getDamageType() == DAMAGE_TYPES.EXPLOSIVE then
            tile = projectile:getPreviousTile();
        end

        hitTile( index, true, tile, projectile );
        return;
    end

    Log.debug( 'Projectile hit destructible world object', 'ProjectileManager' )

    -- Projectiles passing through world objects lose some of their energy.
    local energy = reduceProjectileEnergy( projectile:getEnergy(), worldObject:getEnergyReduction() );
    projectile:setEnergy( energy );

    -- Apply the damage to the tile and only remove it if the energy is 0.
    hitTile( index, energy <= 0, tile, projectile );
    return;
end

---
-- Checks if the projectile has hit any characters or worldobjects.
-- @param index      (number)     The id of the projectile which will be used for removing it.
-- @param projectile (Projectile) The projectile to handle.
-- @param tile       (Tile)       The tile to check.
-- @param character  (Character)  The character who fired this projectile.
--
local function checkForHits( index, projectile, tile, character )
    -- Stop movement and remove the projectile if it has reached the map border.
    if not tile then
        queue:removeProjectile( index );
        return;
    end

    if tile:isOccupied() then
        hitCharacter( index, true, tile, projectile )
    elseif tile:hasWorldObject() then
        hitWorldObject( index, projectile, tile, tile:getWorldObject(), character );
    end

    if projectile:hasReachedTarget() then
        Log.debug( 'Projectile reached target tile', 'ProjectileManager' )
        hitTile( index, true, tile, projectile )
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Initialise the ProjectileManager.
-- @param nmap (Map) The game's map.
--
function ProjectileManager.init( nmap )
    map = nmap;
end

---
-- Updates the ProjectileManager which handles a ProjectileQueue for spawning
-- projectiles and the interaction of each projectile with the game world.
-- @param dt (number) The time since the last frame.
--
function ProjectileManager.update( dt )
    if not queue then
        return;
    end

    -- Updates the time of the projectile queue which handles spawning of
    -- new projectiles.
    queue:update( dt );

    -- Update the projectiles currently in the game world.
    for i, projectile in pairs( queue:getProjectiles() ) do
        projectile:update( dt );

        -- If the projectile has moved notify the world and check if it has
        -- hit anything.
        if projectile:hasMoved( map ) then
            projectile:updateTile( map );
            Messenger.publish( 'PROJECTILE_MOVED', projectile );

            checkForHits( i, projectile, projectile:getTile(), queue:getCharacter() );
        end
    end
end

---
-- Registers a new projectile queue.
-- @param nqueue (ProjectileQueue) The ProjectileQueue to process.
--
function ProjectileManager.register( nqueue )
    queue = nqueue
end

---
-- Remove any saved state.
--
function ProjectileManager.clear()
    queue = nil;
    map = nil;
end

---
-- Returns true if there isn't a queue or if the current queue has been processed.
-- @return (boolean) True if the projectile manager has processed the queue.
--
function ProjectileManager.isDone()
    if not queue then
        return true;
    end
    return queue:isDone();
end

return ProjectileManager;
