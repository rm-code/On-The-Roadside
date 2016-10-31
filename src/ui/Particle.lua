local Object = require( 'src.Object' );

local Particle = {};

function Particle.new()
    local self = Object.new():addInstance( 'Particle' );

    local r, g, b, a, fade, ascii, sprite;

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

    function self:getSprite()
        return sprite;
    end

    function self:setParameters( nr, ng, nb, na, nfade, nascii, nsprite )
        r, g, b, a, fade, ascii, sprite = nr, ng, nb, na, nfade, nascii, nsprite;
    end

    function self:clear()
        r, g, b, a, fade, ascii, sprite = nil, nil, nil, nil, nil, nil, nil;
    end

    return self;
end

return Particle;
