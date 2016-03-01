local Object = require( 'src.Object' );

local SPEED = 10;

local Projectile = {};

function Projectile.new( character, origin, target )
    local self = Object.new():addInstance( 'Projectile' );

    local px, py = origin:getPosition();
    local tx, ty = target:getPosition();

    -- Use the center point of each tile.
    px, py, tx, ty = px + 0.5, py + 0.5, tx + 0.5, ty + 0.5;

    local dx, dy = tx - px, ty - py;
    local magnitude = math.sqrt( dx * dx + dy * dy );
    local normalisedX, normalisedY = dx / magnitude, dy / magnitude;

    function self:update( dt )
        px, py = px + normalisedX * dt * SPEED, py + normalisedY * dt * SPEED;
    end

    function self:getCharacter()
        return character;
    end

    function self:getPosition()
        return px, py;
    end

    function self:getTarget()
        return target;
    end

    return self;
end

return Projectile;
