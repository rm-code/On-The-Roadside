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

local ProjectileQueue = Class( 'ProjectileQueue' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Calculates the amount of shots fired from the weapon.
-- @tparam  Weapon weapon The weapon to generate the projectiles for.
-- @treturn number        The amount of shots fired from the weapon.
--
local function calculateNumberOfShots( weapon )
    return math.min( weapon:getCurrentCapacity(), weapon:getAttacks() )
end

---
-- Spawns a new projectile.
--
local function spawnProjectile( character, weapon, projectiles, target, index )
    local path = ProjectilePath.calculate( character, target, weapon, 1 ) -- TODO Amount of shots
    local projectile = Projectile( character, weapon, path )

    -- Play sound and remove the round from the magazine.
    SoundManager.play( weapon:getSound() )
    weapon:removeRound()

    -- Spawn projectiles for the spread shot.
    if weapon:getEffects():spreadsOnShot() then
        for _ = 1, weapon:getEffects():getPellets() do
            index = index + 1
            local spreadTiles = ProjectilePath.calculate( character, target, weapon, 1 )
            projectiles[index] = Projectile( character, spreadTiles, weapon:getDamage(), weapon:getDamageType(), weapon:getEffects() )
        end
        return
    end

    -- Spawn default projectile.
    index = index + 1
    projectiles[index] = projectile
    return index
end


-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new ProjectileQueue.
--
-- @tparam Character Character The character who started the attack.
-- @tparam Tile target The target tile.
-- @treturn ProjectileQueue A new instance of the ProjectileQueue class.
--
function ProjectileQueue:initialize( character, target )
    self.character = character
    self.target = target

    self.weapon = character:getWeapon()

    self.projectiles = {}
    self.index = 0
    self.timer = 0

    self.numberOfShots = calculateNumberOfShots( self.weapon, self.queue )
end

---
-- Spawns a new projectile after a certain delay defined by the weapon's
-- rate of fire.
-- @tparam number dt Time since the last update in seconds.
--
function ProjectileQueue:update( dt )
    self.timer = self.timer - dt
    if self.timer <= 0 and self.numberOfShots > 0 then
        spawnProjectile( self.character, self.weapon, self.projectiles, self.target, self.index )
        self.timer = self.weapon:getFiringDelay()
        self.numberOfShots = self.numberOfShots - 1
    end
end

---
-- Removes a projectile from the table of active projectiles.
-- @tparam number id The id of the projectile to remove.
--
function ProjectileQueue:removeProjectile( id )
    self.projectiles[id] = nil
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Gets the character this attack was performed by.
-- @treturn Character The character.
--
function ProjectileQueue:getCharacter()
    return self.character
end

---
-- Gets the table of projectiles which are active on the map.
-- @treturn table A table containing the projectiles.
--
function ProjectileQueue:getProjectiles()
    return self.projectiles
end

---
-- Checks if this ProjectileQueue is done with all the projectiles.
-- @treturn boolean True if it is done.
--
function ProjectileQueue:isDone()
    if self.numberOfShots > 0  then
        return false
    end

    local count = 0
    for _, _ in pairs( self.projectiles ) do
        count = count + 1
    end
    return count == 0
end

return ProjectileQueue
