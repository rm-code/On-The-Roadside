---
-- @module ProjectileQueue
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Projectile = require( 'src.items.weapons.Projectile' )
local ProjectilePath = require( 'src.items.weapons.ProjectilePath' )
local Queue = require( 'src.util.Queue' )
local SoundManager = require( 'src.SoundManager' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ProjectileQueue = Class( 'ProjectileQueue' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Enqueues projectiles based on the amount specified by the weapon's current
-- attack mode.
-- @tparam  Weapon weapon The weapon to generate the projectiles for.
-- @tparam  Queue  queue  The queue to fill.
-- @treturn number        The amount of shots fired from the weapon.
--
local function calculateShots( weapon, queue )
    local shots = math.min( weapon:getMagazine():getNumberOfRounds(), weapon:getAttacks() )
    for i = 1, shots do
        queue:enqueue( weapon:getMagazine():getRound( i ))
    end
    return shots
end

---
-- Removes a projectile from the queue and adds it to the table of active
-- projectiles.
--
local function spawnProjectile( queue, character, weapon, shots, projectiles, tx, ty, th, index )
    local round = queue:dequeue()

    local path = ProjectilePath.calculate( character, tx, ty, th, weapon, shots - queue:getSize() )
    local projectile = Projectile( character, path, weapon:getDamage(), round:getDamageType(), round:getEffects() )

    -- Play sound and remove the round from the magazine.
    SoundManager.play( weapon:getSound() )
    weapon:getMagazine():removeRound()

    -- Spawn projectiles for the spread shot.
    if round:getEffects():spreadsOnShot() then
        for _ = 1, round:getEffects():getPellets() do
            index = index + 1
            local spreadTiles = ProjectilePath.calculate( character, tx, ty, th, weapon, shots - queue:getSize() )
            projectiles[index] = Projectile( character, spreadTiles, weapon:getDamage(), round:getDamageType(), round:getEffects() )
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
-- @tparam number    tx        The target's x-coordinate.
-- @tparam number    ty        The target's y-coordinate.
-- @tparam number    th        The target's height.
-- @treturn ProjectileQueue A new instance of the ProjectileQueue class.
--
function ProjectileQueue:initialize( character, tx, ty, th )
    self.character = character
    self.targetX = tx
    self.targetY = ty
    self.targetHeight = th

    self.weapon = character:getWeapon()

    self.queue = Queue()
    self.projectiles = {}
    self.index = 0
    self.timer = 0

    self.shots = calculateShots( self.weapon, self.queue )
end

---
-- Spawns a new projectile after a certain delay defined by the weapon's
-- rate of fire.
-- @tparam number dt Time since the last update in seconds.
--
function ProjectileQueue:update( dt )
    self.timer = self.timer - dt
    if self.timer <= 0 and not self.queue:isEmpty() then
        spawnProjectile( self.queue, self.character, self.weapon, self.shots, self.projectiles, self.targetX, self.targetY, self.targetHeight, self.index )
        self.timer = self.weapon:getFiringDelay()
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
    if not self.queue:isEmpty() then
        return false
    end

    local count = 0
    for _, _ in pairs( self.projectiles ) do
        count = count + 1
    end
    return count == 0
end

return ProjectileQueue
