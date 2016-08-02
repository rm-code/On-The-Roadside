local Object = require( 'src.Object' );

local Particle = {};

function Particle.new()
    local self = Object.new():addInstance( 'Particle' );

    local r, g, b, a, fade;

    function self:update( dt )
        a = a - dt * fade;
    end

    function self:getColors()
        return r, g, b, a;
    end

    function self:getAlpha()
        return a;
    end

    function self:setParameters( nr, ng, nb, na, nfade )
        r, g, b, a, fade = nr, ng, nb, na, nfade;
    end

    function self:clear()
        r, g, b, a, fade = nil, nil, nil, nil, nil;
    end

    return self;
end

return Particle;
