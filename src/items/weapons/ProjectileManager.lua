local Log = require( 'src.util.Log' );
local Messenger = require( 'src.Messenger' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local Util = require( 'src.util.Util' )
local MessageQueue = require( 'src.util.MessageQueue' )
local Translator = require( 'src.util.Translator' )

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
-- @param tile       (Tile)       The tile to hit.
-- @param projectile (Projectile) The projectile to remove.
--
local function hitTile( tile, projectile )
    if projectile:getDamageType() == DAMAGE_TYPES.EXPLOSIVE then
        ExplosionManager.register( tile, projectile:getDamage(), projectile:getEffects():getBlastRadius() )
        return
    end

    tile:hit( projectile:getDamage() * ( projectile:getEnergy() / 100 ), projectile:getDamageType() )
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
local function hitCharacter( tile, projectile )
    MessageQueue.enqueue( string.format( Translator.getText( 'msg_hit_character' ), tile:getCharacter():getName() ), 'WARNING' )
    Log.debug( 'Projectile hit character', 'ProjectileManager' )
    hitTile( tile, projectile )
    return true
end

---
-- Handles how to proceed if the projectile hits a world object.
-- @param projectile  (Projectile)  The projectile to handle.
-- @param tile        (Tile)        The tile to check.
-- @param worldObject (WorldObject) The world object to check.
-- @treturn boolean Wether to remove the projectile or not.
--
local function hitWorldObject( projectile, tile, worldObject )
    if projectile:getHeight() > worldObject:getHeight() then
        Log.debug( 'Projectile flies over world object', 'ProjectileManager' )
        return false
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

        MessageQueue.enqueue( string.format( Translator.getText( 'msg_hit_indestructible_worldobject' ), Translator.getText( worldObject:getID() )), 'INFO' )
        hitTile( tile, projectile )
        return true
    end

    Log.debug( 'Projectile hit destructible world object', 'ProjectileManager' )

    -- Projectiles passing through world objects lose some of their energy.
    local energy = reduceProjectileEnergy( projectile:getEnergy(), worldObject:getEnergyReduction() );
    projectile:setEnergy( energy );

    MessageQueue.enqueue( string.format( Translator.getText( 'msg_hit_worldobject' ), Translator.getText( worldObject:getID() ), projectile:getDamage() ), 'INFO' )

    -- Apply the damage to the tile and only remove it if the energy is 0.
    hitTile( tile, projectile )
    return energy <= 0
end

---
-- Checks if the projectile has hit any characters or worldobjects.
-- @param index      (number)     The id of the projectile which will be used for removing it.
-- @param projectile (Projectile) The projectile to handle.
-- @param tile       (Tile)       The tile to check.
-- @param character  (Character)  The character who fired this projectile.
--
local function checkForHits( index, projectile, tile )
    -- Stop movement and remove the projectile if it has reached the map border.
    if not tile then
        queue:removeProjectile( index )
        return
    end

    local remove = false

    if tile:isOccupied() then
        remove = hitCharacter( tile, projectile )
    elseif tile:hasWorldObject() then
        remove = hitWorldObject( projectile, tile, tile:getWorldObject() )
    end

    if projectile:hasReachedTarget() then
        Log.debug( 'Projectile reached target tile', 'ProjectileManager' )
        hitTile( tile, projectile )
        remove = true
    end

    if remove then
        queue:removeProjectile( index )
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

            checkForHits( i, projectile, projectile:getTile() )
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
