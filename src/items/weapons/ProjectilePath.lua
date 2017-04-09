local Stances = require('src.constants.Stances');
local Bresenham = require( 'lib.Bresenham' );
local VectorMath = require( 'src.util.VectorMath' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ProjectilePath = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MARKSMAN_SKILL_MODIFIERS = {
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

local RANGED_WEAPON_MODIFIERS = {
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

local RANGED_BURST_MODIFIERS = {
    [1] =  0,
    [2] =  2,
    [3] =  3,
    [4] =  4,
    [5] =  6,
    [6] =  7,
    [7] =  8,
    [8] =  9,
    [9] = 10
}

local RANGED_STANCE_MODIFIER = {
    [Stances.STAND]  = 1.0,
    [Stances.CROUCH] = 0.7,
    [Stances.PRONE]  = 0.5,
}

local THROWN_STANCE_MODIFIERS = {
    [Stances.STAND]  = 1.0,
    [Stances.CROUCH] = 0.7,
    [Stances.PRONE]  = 1.2, -- Throwing should be harder from a prone stance.
}

local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

-- ------------------------------------------------
-- Local Functions
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
-- @param character (Character) The character shooting the weapon.
-- @param weapon    (Weapon)    The used weapon.
-- @param count     (number)    Determines how many projectiles have been fired already.
-- @return          (number)    The maximum range for the derivation.
--
local function calculateRangedMaximumDerivation( character, weapon, count )
    local marksmanSkill = roundToMultipleOfTen( character:getAccuracy() );
    local weaponAccuracy = roundToMultipleOfTen( weapon:getAccuracy() );

    local derivation = 0;
    -- Random angle based on the character's accuracy skill.
    derivation = derivation + MARKSMAN_SKILL_MODIFIERS[marksmanSkill];
    -- Random angle based on weapon's accuracy stat.
    derivation = derivation + RANGED_WEAPON_MODIFIERS[weaponAccuracy];
    -- Random angle based on how many bullets have been shot before.
    derivation = derivation + RANGED_BURST_MODIFIERS[math.min( count, #RANGED_BURST_MODIFIERS )];

    -- Stances influence the whole angle.
    derivation = derivation * RANGED_STANCE_MODIFIER[character:getStance()];

    return derivation;
end

---
-- Calculates the maximum angle of derivation for the shot.
-- @param character (Character) The character throwing the weapon.
-- @return  (number) The maximum range for the derivation.
--
local function calculateThrownMaximumDerivation( character )
    local throwingSkill = roundToMultipleOfTen( character:getThrowingSkill() );

    local derivation = 0;
    -- Random angle based on the character's accuracy skill.
    derivation = derivation + THROWING_SKILL_MODIFIERS[throwingSkill];

    -- Stances influence the whole angle.
    derivation = derivation * THROWN_STANCE_MODIFIERS[character:getStance()];

    return derivation;
end

---
-- Determine the height falloff for a projectile.
-- This is achieved by taking the height at the origin of the attack and the
-- height of the target.
-- The height of the target is halved and a random value is either added to or
-- subtracted from it. The random value is based on half the target's size and
-- an additional modifier.
-- @tparam  Tile   origin The starting tile.
-- @tparam  Tile   target The target tile.
-- @tparam  number steps  The distance to the target.
-- @treturn number        The calculated falloff value.
--
local function calculateFalloff( origin, target, steps )
    local oheight = origin:getHeight()
    local theight = target:getHeight()

    -- TODO base on skills?
    -- This takes the center of the target and adds or subtracts a random value
    -- based on the half size of the target with a constant modifier added to it.
    local usedHeight = theight * 0.5 + randomSign() * love.math.random( theight * 0.5 + 10 )

    local delta = oheight - usedHeight
    return delta / steps
end


-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Helper function which picks the right calculation function based on the
-- weapon's type.
-- @param character (Character) The character shooting the weapon.
-- @param weapon    (Weapon)    The used weapon.
-- @param count     (number)    Determines how many projectiles have been fired already.
-- @return          (number)    The maximum range for the derivation.
--
function ProjectilePath.getMaximumDerivation( character, weapon, count )
    if weapon:getSubType() == WEAPON_TYPES.RANGED then
        return calculateRangedMaximumDerivation( character, weapon, count );
    elseif weapon:getSubType() == WEAPON_TYPES.THROWN then
        return calculateThrownMaximumDerivation( character );
    else
        error( string.format( 'Can\'t calculate a derivation for selected weapon type %s!', weapon:getSubType() ));
    end
end

---
-- Creates the path for a particular projectile.
-- @param character (Character) The character shooting the weapon.
-- @param target    (Tile)      The target tile.
-- @param weapon    (Weapon)    The used weapon.
-- @param count     (number)    Determines how many projectiles have been fired already.
-- @return          (table)     A sequence containing all tiles of the projectile's path.
--
function ProjectilePath.calculate( character, target, weapon, count )
    -- Calculate the angle of derivation.
    local maxDerivation = ProjectilePath.getMaximumDerivation( character, weapon, count );
    local actualDerivation = randomSign() * getRandomAngle( maxDerivation );

    -- Apply the angle to find the final target tile.
    local origin = character:getTile();
    local px, py = origin:getPosition();
    local tx, ty = target:getPosition();

    local nx, ny = VectorMath.rotate( px, py, tx, ty, actualDerivation, love.math.random( 90, 130 ) / 100 );
    nx, ny = math.floor( nx + 0.5 ), math.floor( ny + 0.5 );

    -- Determine the height falloff for the projectile.
    local _, steps = Bresenham.line( px, py, nx, ny )
    local falloff = calculateFalloff( origin, target, steps )

    -- Get the coords of all tiles the projectile passes on the way to its target.
    local tiles = {};
    Bresenham.line( px, py, nx, ny, function( sx, sy, counter )
        -- Ignore the origin.
        if sx ~= px or sy ~= py then
            tiles[#tiles + 1] = { x = sx, y = sy, z = origin:getHeight() - (counter+1) * falloff }
        end
        return true;
    end)

    return tiles;
end

return ProjectilePath;
