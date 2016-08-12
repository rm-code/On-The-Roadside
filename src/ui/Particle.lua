local Object = require( 'src.Object' );

local Particle = {};

function Particle.new()
    local self = Object.new():addInstance( 'Particle' );

    local r, g, b, a, fade, ascii;

    function self:update( dt )
        a = a - dt * fade;
    end

    function self:getColors()
        return r, g, b, a;
    end

    function self:getAlpha()
        return a;
    end

    function self:isAscii()
        return ascii;
    end

    function self:setParameters( nr, ng, nb, na, nfade, nascii )
        r, g, b, a, fade, ascii = nr, ng, nb, na, nfade, nascii;
    end

    function self:clear()
        r, g, b, a, fade, ascii = nil, nil, nil, nil, nil, nil;
    end

    return self;
end

return Particle;
