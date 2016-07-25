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

    local function randomSign()
        return love.math.random( 0, 1 ) == 0 and -1 or 1;
    end

    local function round( value )
        return math.floor( value / 10 + 0.5 ) * 10;
    end

    local function getRandomAngle( angle )
        return love.math.random( angle * 100 ) / 100;
    end

    local function calculateMaximumDerivation()
        local marksmanSkill = round( character:getAccuracy() );
        local weaponAccuracy = round( weapon:getAccuracy() );

        return getRandomAngle( SKILL_MODIFIERS[marksmanSkill] ) + getRandomAngle( WEAPON_MODIFIERS[weaponAccuracy] );
    end

    local function determineActualDerivation( angle )
        return getRandomAngle( angle );
    end

    local function spawnProjectile()
        index = index + 1;
        projectiles[index] = projectileQueue:dequeue();
        Messenger.publish( 'SOUND_SHOOT' );
        weapon:shoot();
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        local amount = math.min( weapon:getMagazine():getRounds(), weapon:getShots() );
        for _ = 1, amount do
            local maxDerivation = calculateMaximumDerivation();
            local actualDerivation = randomSign() * determineActualDerivation( maxDerivation );
            projectileQueue:enqueue( Projectile.new( character, character:getTile(), target, actualDerivation ));
        end
    end

    function self:update( dt )
        timer = timer - dt;
        if timer <= 0 and not projectileQueue.isEmpty() then
            spawnProjectile();
            timer = delay;
        end
    end

    function self:removeProjectile( id )
        projectiles[id] = nil;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getCharacter()
        return character;
    end

    function self:getProjectiles()
        return projectiles;
    end

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
