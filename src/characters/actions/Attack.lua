local Action = require('src.characters.actions.Action');
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );

local Attack = {};

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

function Attack.new( character, target )
    local self = Action.new( character:getWeapon():getAttackCost() ):addInstance( 'Attack' );

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
        local weaponAccuracy = round( character:getWeapon():getAccuracy() );

        return getRandomAngle( SKILL_MODIFIERS[marksmanSkill] ) + getRandomAngle( WEAPON_MODIFIERS[weaponAccuracy] );
    end

    local function determineActualDerivation( angle )
        return getRandomAngle( angle );
    end

    function self:perform()
        local origin = character:getTile();

        for _ = 1, character:getWeapon():getShots() do
            local maxDerivation = calculateMaximumDerivation();
            local actualDerivation = randomSign() * determineActualDerivation( maxDerivation );
            ProjectileManager.register( character, origin, target, actualDerivation );
        end

        character:removeLineOfSight();
    end

    return self;
end

return Attack;
