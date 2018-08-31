---
-- @module ProjectileManager
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Observable = require( 'src.util.Observable' )
local Log = require( 'src.util.Log' )
local Util = require( 'src.util.Util' )
local Translator = require( 'src.util.Translator' )

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
        self:publish( 'CREATE_EXPLOSION', tile, projectile:getDamage(), projectile:getEffects():getBlastRadius() )
        return
    end

    tile:hit( projectile:getDamage() * ( projectile:getEnergy() / 100 ), projectile:getDamageType() )
end

---
-- Reduces the energy of the projectile with slightly randomized values.
-- @tparam  number energy    The current energy.
-- @tparam  number reduction The reduction that should be applied.
-- @treturn number           The modified energy value.
--
local function reduceProjectileEnergy( energy, reduction )
    reduction = love.math.random( reduction - 10, reduction + 10 )
    reduction = Util.clamp( 1, reduction, 100 )
    return energy - reduction
end

---
-- Hits a character.
-- @tparam Tile       tile       The tile to hit.
-- @tparam Projectile projectile The projectile to remove.
--
local function hitCharacter( self, tile, projectile )
    Log.debug( 'Projectile hit character', 'ProjectileManager' )
    hitTile( self, tile, projectile )
    return true
end

---
-- Handles how to proceed if the projectile hits a world object.
-- @tparam  Projectile  projectile  The projectile to handle.
-- @tparam  Tile        tile        The tile to check.
-- @tparam  WorldObject worldObject The world object to check.
-- @treturn boolean                 Wether to remove the projectile or not.
--
local function hitWorldObject( self, projectile, tile, worldObject )
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
            tile = projectile:getPreviousTile()
        end

        tile:publish( 'MESSAGE_LOG_EVENT', tile, string.format( Translator.getText( 'msg_hit_indestructible_worldobject' ), Translator.getText( worldObject:getID() )), 'INFO' )
        hitTile( self, tile, projectile )
        return true
    end

    Log.debug( 'Projectile hit destructible world object', 'ProjectileManager' )

    -- Projectiles passing through world objects lose some of their energy.
    local energy = reduceProjectileEnergy( projectile:getEnergy(), worldObject:getEnergyReduction() )
    projectile:setEnergy( energy )

    tile:publish( 'MESSAGE_LOG_EVENT', tile, string.format( Translator.getText( 'msg_hit_worldobject' ), Translator.getText( worldObject:getID() ), projectile:getDamage() ), 'INFO' )

    -- Apply the damage to the tile and only remove it if the energy is 0.
    hitTile( self, tile, projectile )
    return energy <= 0
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

    local remove = false

    if tile:hasCharacter() then
        remove = hitCharacter( self, tile, projectile )
    elseif tile:hasWorldObject() then
        remove = hitWorldObject( self, projectile, tile, tile:getWorldObject() )
    end

    if not remove and projectile:hasReachedTarget() then
        Log.debug( 'Projectile reached target tile', 'ProjectileManager' )
        hitTile( self, tile, projectile )
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
