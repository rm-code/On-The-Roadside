local Object = require( 'src.Object' );

local Particle = {};

function Particle.new( r, g, b, a )
    local self = Object.new():addInstance( 'Particle' );

    function self:update( dt )
        a = a - dt * 500;
    end

    function self:getColors()
        return r, g, b, a;
    end

    function self:getAlpha()
        return a;
    end

    return self;
end

return Particle;
