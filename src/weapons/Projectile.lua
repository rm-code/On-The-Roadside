local Object = require( 'src.Object' );

local SPEED = 10;

local CHANCES = {
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

local Projectile = {};

local function randomSign()
    return love.math.random( 0, 1 ) == 0 and -1 or 1;
end

local function isAccurateShot( chanceToHit )
    return love.math.random( 100 ) <= chanceToHit;
end

local function getShotAngle( chanceToHit )
    if chanceToHit >= 100 then
        return CHANCES[100];
    elseif chanceToHit >= 90 then
        return CHANCES[90];
    elseif chanceToHit >= 80 then
        return CHANCES[80];
    elseif chanceToHit >= 70 then
        return CHANCES[70];
    elseif chanceToHit >= 60 then
        return CHANCES[60];
    elseif chanceToHit >= 50 then
        return CHANCES[50];
    elseif chanceToHit >= 40 then
        return CHANCES[40];
    elseif chanceToHit >= 30 then
        return CHANCES[30];
    elseif chanceToHit >= 20 then
        return CHANCES[20];
    elseif chanceToHit >= 10 then
        return CHANCES[10];
    end
    return CHANCES[0];
end

local function calculateShotDeviation( px, py, tx, ty, angle )
    local vx, vy = tx - px, ty - py;

    angle = love.math.random() * angle * randomSign();
    angle = math.rad( angle );

    print( math.deg( angle ) .. "° from target." );

    local nx = vx * math.cos( angle ) - vy * math.sin( angle );
    local ny = vx * math.sin( angle ) + vy * math.cos( angle );

    return px + nx, py + ny;
end

function Projectile.new( character, damage, origin, target )
    local self = Object.new():addInstance( 'Projectile' );

    local px, py = origin:getPosition();
    local tx, ty = target:getPosition();

    local chanceToHit = character:getAccuracy() * ( character:getWeapon():getAccuracy() / 100 );

    print("CTH: " .. chanceToHit);

    if not isAccurateShot( chanceToHit ) then
        local angle = getShotAngle( chanceToHit );
        print("Inaccurate shot.");
        tx, ty = calculateShotDeviation( px, py, tx, ty, angle );
    else
        print("Accurate shot.");
        tx, ty = tx + 0.5, ty + 0.5;
    end

    px, py = px + 0.5, py + 0.5;

    local dx, dy = tx - px, ty - py;
    local magnitude = math.sqrt( dx * dx + dy * dy );
    local normalisedX, normalisedY = dx / magnitude, dy / magnitude;

    function self:update( dt )
        px, py = px + normalisedX * dt * SPEED, py + normalisedY * dt * SPEED;
    end

    function self:getCharacter()
        return character;
    end

    function self:getDamage()
        return damage;
    end

    function self:getPosition()
        return px, py;
    end

    function self:getTilePosition()
        return math.floor( px ), math.floor( py );
    end

    function self:getTarget()
        return target;
    end

    return self;
end

return Projectile;
