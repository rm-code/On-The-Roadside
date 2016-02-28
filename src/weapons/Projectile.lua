local Object = require( 'src.Object' );

local SPEED = 10;

local Projectile = {};

function Projectile.new( character, px, py, tx, ty )
    local self = Object.new():addInstance( 'Projectile' );

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

    return self;
end

return Projectile;
