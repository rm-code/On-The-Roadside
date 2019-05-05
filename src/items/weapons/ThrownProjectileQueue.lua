---
-- @module ProjectileQueue
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Projectile = require( 'src.items.weapons.Projectile' )
local ProjectilePath = require( 'src.items.weapons.ProjectilePath' )
local SoundManager = require( 'src.SoundManager' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ThrownProjectileQueue = Class( 'ThrownProjectileQueue' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new ThrownProjectileQueue.
--
-- @tparam Character Character The character who started the attack.
-- @tparam number    tx        The target's x-coordinate.
-- @tparam number    ty        The target's y-coordinate.
-- @tparam number    th        The target's height.
--
function ThrownProjectileQueue:initialize( character, tx, ty, th )
    self.character = character

    self.weapon = character:getWeapon()

    assert( self.weapon:getSubType() == WEAPON_TYPES.THROWN, 'Expected a weapon of type Thrown.' )

    self.projectiles = {}
    self.index = 0

    -- Thrown weapon is removed from the inventory.
    local success = character:getEquipment():searchAndRemoveItem( self.weapon )
    assert( success, "Couldn't remove the item from the character's equipment." )

    local tiles = ProjectilePath.calculate( character, tx, ty, th, self.weapon )
    local projectile = Projectile( character, self.weapon, tiles )
    self.index = self.index + 1
    self.projectiles[self.index] = projectile

    -- Play sound.
    SoundManager.play( self.weapon:getSound() )
end

---
-- Spawns a new projectile after a certain delay defined by the weapon's
-- rate of fire.
--
function ThrownProjectileQueue:update()
    return
end

---
-- Removes a projectile from the table of active projectiles.
-- @tparam number id The id of the projectile to remove.
--
function ThrownProjectileQueue:removeProjectile( id )
    self.projectiles[id] = nil
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Gets the character this attack was performed by.
-- @treturn Character The character.
--
function ThrownProjectileQueue:getCharacter()
    return self.character
end

---
-- Gets the table of projectiles which are active on the map.
-- @treturn table A table containing the projectiles.
--
function ThrownProjectileQueue:getProjectiles()
    return self.projectiles
end

---
-- Checks if this ThrownProjectileQueue is done with all the projectiles.
-- @treturn boolean True if it is done.
--
function ThrownProjectileQueue:isDone()
    local count = 0
    for _, _ in pairs( self.projectiles ) do
        count = count + 1
    end
    return count == 0
end

return ThrownProjectileQueue
