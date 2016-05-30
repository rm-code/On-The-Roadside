local Object = require( 'src.Object' );

local SPEED = 30;

local Projectile = {};

local function applyVectorRotation( px, py, tx, ty, angle )
    local vx, vy = tx - px, ty - py;

    -- Transform angle from degrees to radians.
    angle = math.rad( angle );

    local nx = vx * math.cos( angle ) - vy * math.sin( angle );
    local ny = vx * math.sin( angle ) + vy * math.cos( angle );

    return px + nx, py + ny;
end

function Projectile.new( character, origin, target, angle )
    local self = Object.new():addInstance( 'Projectile' );

    local weapon = character:getWeapon();

    local px, py = origin:getPosition();
    local tx, ty = target:getPosition();

    tx, ty = applyVectorRotation( px, py, tx, ty, angle );

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
        return weapon:getDamage();
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

    function self:getWeapon()
        return weapon;
    end

    return self;
end

return Projectile;
