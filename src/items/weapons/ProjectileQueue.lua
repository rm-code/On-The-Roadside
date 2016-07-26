local Projectile = require( 'src.items.weapons.Projectile' );
local Queue = require( 'src.util.Queue' );
local Messenger = require( 'src.Messenger' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ProjectileQueue = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SKILL_MODIFIERS = {
      [0] = 30,
     [10] = 28,
     [20] = 25,
     [30] = 23,
     [40] = 20,
     [50] = 15,
     [60] = 11,
     [70] =  8,
     [80] =  4,
     [90] =  2,
    [100] =  1,
}

local WEAPON_MODIFIERS = {
    [0] = 27,
   [10] = 23,
   [20] = 20,
   [30] = 17,
   [40] = 14,
   [50] = 11,
   [60] =  8,
   [70] =  5,
   [80] =  3,
   [90] =  1,
  [100] =  0,
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new ProjectileQueue.
-- @param character (Character)       The character who started the attack.
-- @param target    (Tile)            The target tile.
-- @return          (ProjectileQueue) A new instance of the ProjectileQueue class.
--
function ProjectileQueue.new( character, target )
    local self = {};

    local projectileQueue = Queue.new();
    local projectiles = {};
    local index = 0;
    local timer = 0;
    local weapon = character:getEquipment():getWeapon();
    local delay = weapon:getFiringDelay();

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Returns a random sign.
    -- @return (number) Either one or minus one.
    --
    local function randomSign()
        return love.math.random( 0, 1 ) == 0 and -1 or 1;
    end

    ---
    -- Rounds a value to the next multiple of ten.
    -- @param value (number) The value to round.
    -- @return      (number) The rounded value.
    --
    local function roundToMultipleOfTen( value )
        return math.floor( value / 10 + 0.5 ) * 10;
    end

    ---
    -- Generates a random angle in the specified range.
    -- @param range (number) The range to choose from.
    -- @return      (number) The random angle.
    --
    local function getRandomAngle( range )
        return love.math.random( range * 100 ) / 100;
    end

    ---
    -- Calculates the maximum angle of derivation for the shot.
    -- @return (number) The maximum range for the derivation.
    --
    local function calculateMaximumDerivation()
        local marksmanSkill = roundToMultipleOfTen( character:getAccuracy() );
        local weaponAccuracy = roundToMultipleOfTen( weapon:getAccuracy() );

        return getRandomAngle( SKILL_MODIFIERS[marksmanSkill] ) + getRandomAngle( WEAPON_MODIFIERS[weaponAccuracy] );
    end

    ---
    -- Removes a projectile from the queue and adds it to the table of active
    -- projectiles.
    --
    local function spawnProjectile()
        index = index + 1;
        projectiles[index] = projectileQueue:dequeue();
        Messenger.publish( 'SOUND_SHOOT' );
        weapon:shoot();
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Generates projectiles based on the weapons firing mode. The value is
    -- limited by the amount of rounds in the weapon's magazine. For each
    -- projectile an angle of derivation is calculated before it is placed in
    -- the queue.
    --
    function self:init()
        local amount = math.min( weapon:getMagazine():getRounds(), weapon:getShots() );
        for _ = 1, amount do
            local maxDerivation = calculateMaximumDerivation();
            local actualDerivation = randomSign() * getRandomAngle( maxDerivation );
            projectileQueue:enqueue( Projectile.new( character, character:getTile(), target, actualDerivation ));
        end
    end

    ---
    -- Spawns a new projectile after a certain delay defined by the weapon's
    -- rate of fire.
    --
    function self:update( dt )
        timer = timer - dt;
        if timer <= 0 and not projectileQueue.isEmpty() then
            spawnProjectile();
            timer = delay;
        end
    end

    ---
    -- Removes a projectile from the table of active projectiles.
    -- @param id (number) The id of the projectile to remove.
    --
    function self:removeProjectile( id )
        projectiles[id] = nil;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Gets the character this attack was performed by.
    -- @return (Character) The character.
    --
    function self:getCharacter()
        return character;
    end

    ---
    -- Gets the table of projectiles which are active on the map.
    -- @return (table) A table containing the projectiles.
    function self:getProjectiles()
        return projectiles;
    end

    ---
    -- Checks if this ProjectileQueue is done with all the projectiles.
    -- @return (boolean) True if it is done.
    --
    function self:isDone()
        if not projectileQueue.isEmpty() then
            return false;
        end

        local count = 0;
        for _, _ in pairs( projectiles ) do
            count = count + 1;
        end
        return count == 0;
    end

    return self;
end

return ProjectileQueue;
