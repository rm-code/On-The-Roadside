local Projectile = require( 'src.items.weapons.Projectile' );
local Messenger = require( 'src.Messenger' );
local Bresenham = require( 'lib.Bresenham' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ThrownProjectileQueue = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local THROWING_SKILL_MODIFIERS = {
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

local STANCES = require('src.constants.Stances');
local STANCE_MODIFIER = {
    [STANCES.STAND]  = 1.0,
    [STANCES.CROUCH] = 0.7,
    [STANCES.PRONE]  = 1.2, -- Throwing should be harder from a prone stance.
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new ThrownProjectileQueue.
-- @param character (Character)       The character who started the attack.
-- @param target    (Tile)            The target tile.
-- @return          (ThrownProjectileQueue) A new instance of the ThrownProjectileQueue class.
--
function ThrownProjectileQueue.new( character, target )
    local self = {};

    local projectiles = {};
    local index = 0;
    local weapon = character:getInventory():getWeapon();

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
    -- @return  (number) The maximum range for the derivation.
    --
    local function calculateMaximumDerivation()
        local throwingSkill = roundToMultipleOfTen( character:getThrowingSkill() );

        local derivation = 0;
        -- Random angle based on the character's accuracy skill.
        derivation = derivation + THROWING_SKILL_MODIFIERS[throwingSkill];

        -- Stances influence the whole angle.
        derivation = derivation * STANCE_MODIFIER[character:getStance()];

        return derivation;
    end

    ---
    -- Rotates the target position by the given angle.
    -- @param px    (number)
    -- @param py    (number)
    -- @param tx    (number)
    -- @param ty    (number)
    -- @param angle (number)
    -- @return      (number) The new target along the x-axis.
    -- @return      (number) The new target along the y-axis.
    --
    local function applyVectorRotation( px, py, tx, ty, angle )
        local vx, vy = tx - px, ty - py;

        -- Vary the shot distance randomly.
        local factor = love.math.random( 90, 130 ) / 100;
        vx = vx * factor;
        vy = vy * factor;

        -- Transform angle from degrees to radians.
        angle = math.rad( angle );

        local nx = vx * math.cos( angle ) - vy * math.sin( angle );
        local ny = vx * math.sin( angle ) + vy * math.cos( angle );

        return px + nx, py + ny;
    end

    ---
    -- Creates a projectile path.
    -- @return  (Projectile) The new projectile instance.
    --
    local function createProjectilePath()
        -- Calculate the angle of derivation.
        local maxDerivation = calculateMaximumDerivation();
        local actualDerivation = randomSign() * getRandomAngle( maxDerivation );

        -- Apply the angle to find the final target tile.
        local origin = character:getTile();
        local px, py = origin:getPosition();
        local tx, ty = target:getPosition();

        local nx, ny = applyVectorRotation( px, py, tx, ty, actualDerivation );
        nx, ny = math.floor( nx + 0.5 ), math.floor( ny + 0.5 );

        -- Get the coords of all tiles the projectile passes on the way to its target.
        local tiles = {};
        Bresenham.calculateLine( px, py, nx, ny, function( sx, sy )
            -- Ignore the origin.
            if sx ~= px or sy ~= py then
                tiles[#tiles + 1] = { x = sx, y = sy };
            end
            return true;
        end)

        return tiles;
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
        assert( weapon:getWeaponType() == 'Thrown', 'Expected a weapon of type Thrown.' );

        -- Thrown weapon is removed from the inventory.
        character:getInventory():removeItem( weapon );

        local tiles = createProjectilePath();
        local projectile = Projectile.new( character, tiles, weapon:getDamage(), weapon:getEffects() );
        index = index + 1;
        projectiles[index] = projectile;

        -- Play sound.
        Messenger.publish( 'SOUND_ATTACK', weapon );
    end

    ---
    -- Spawns a new projectile after a certain delay defined by the weapon's
    -- rate of fire.
    --
    function self:update()
        return;
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
    -- Gets the table of projectiles which are active on the map.
    -- @return (table) A table containing the projectiles.
    function self:getProjectiles()
        return projectiles;
    end

    ---
    -- Checks if this ThrownProjectileQueue is done with all the projectiles.
    -- @return (boolean) True if it is done.
    --
    function self:isDone()
        local count = 0;
        for _, _ in pairs( projectiles ) do
            count = count + 1;
        end
        return count == 0;
    end

    return self;
end

return ThrownProjectileQueue;
