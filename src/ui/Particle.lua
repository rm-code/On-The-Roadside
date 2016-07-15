local Object = require( 'src.Object' );

local Particle = {};

function Particle.new()
    local self = Object.new():addInstance( 'Particle' );

    local r, g, b, a;

    function self:update( dt )
        a = a - dt * 500;
    end

    function self:getColors()
        return r, g, b, a;
    end

    function self:getAlpha()
        return a;
    end

    function self:setParameters( nr, ng, nb, na )
        r, g, b, a = nr, ng, nb, na;
    end

    function self:clear()
        r, g, b, a = nil, nil, nil, nil;
    end

    return self;
end

return Particle;
