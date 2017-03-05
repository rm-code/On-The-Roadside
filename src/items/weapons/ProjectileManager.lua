local Log = require( 'src.util.Log' );
local Messenger = require( 'src.Messenger' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );

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
        ExplosionManager.register( tile, projectile:getEffects():getBlastRadius() );
        return;
    end

    tile:hit( projectile:getDamage() * ( projectile:getEnergy() / 100 ), projectile:getDamageType() );
end

---
-- Clamps a value to a certain range.
-- @param min (number) The minimum value to clamp to.
-- @param val (number) The value to clamp.
-- @param max (number) The maximum value to clamp to.
-- @return    (number) The clamped value.
--
local function clamp( min, val, max )
    return math.max( min, math.min( val, max ));
end

---
-- Reduces the energy of the projectile with slightly randomized values.
-- @params energy    (number) The current energy.
-- @params reduction (number) The reduction that should be applied.
-- @return           (number) The modified energy value.
--
local function reduceProjectileEnergy( energy, reduction )
    reduction = love.math.random( reduction - 10, reduction + 10 );
    reduction = clamp( 1, reduction, 100 );
    return energy - reduction;
end

---
-- Handles how to proceed if the projectile hits a world object.
-- @param index       (number)      The id of the projectile which will be used for removing it.
-- @param projectile  (Projectile)  The projectile to handle.
-- @param tile        (Tile)        The tile to check.
-- @param worldObject (WorldObject) The world object to check.
-- @param character   (Character)   The character who fired this projectile.
--
local function hitWorldObject( index, projectile, tile, worldObject, character )
    -- World objects which are on a tile directly adjacent to the attacking
    -- character will be ignored if they either are destructible or don't fill
    -- the whole tile. Indestructible objects which cover the whole tile will
    -- still block the shot.
    if tile:isAdjacent( character:getTile() ) and ( worldObject:isDestructible() or worldObject:getSize() < 100 ) then
        Log.debug( 'World object is adjacent to character and will be ignored', 'ProjectileManager' );
        return;
    end

    -- Roll a random number. This is the chance to hit a world object based on
    -- its size. So larger world objects have a higher chance to block shots.
    if love.math.random( 100 ) > worldObject:getSize() then
        return;
    end

    -- Remove projectiles when they hit indestructible world objects.
    if not worldObject:isDestructible() then
        -- Explosive projectiles explode on the previous tile once they hit an
        -- indestructible world object. This needs to be done to make sure explosions
        -- occur on the right side of the world object.
        if projectile:getDamageType() == DAMAGE_TYPES.EXPLOSIVE then
            tile = projectile:getPreviousTile();
        end

        hitTile( index, true, tile, projectile );
        return;
    end

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

    -- Hit the tile if it is occupied by a character or the target of the attack.
    if tile:isOccupied() or projectile:hasReachedTarget() then
        hitTile( index, true, tile, projectile );
        return;
    end

    -- Handle world objects.
    if tile:hasWorldObject() then
        hitWorldObject( index, projectile, tile, tile:getWorldObject(), character );
        return;
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
    queue = nqueue;
    queue:init();
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
