local Object = require( 'src.Object' );

local Projectile = {};

function Projectile.new( character, px, py, tx, ty )
    local self = Object.new():addInstance( 'Projectile' );

    local dx, dy = tx - px, ty - py;

    function self:update( dt )
        px, py = px + dx * dt * 2, py + dy * dt * 2;
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
