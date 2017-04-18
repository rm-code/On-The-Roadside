local Object = require( 'src.Object' );

local Particle = {};

function Particle.new()
    local self = Object.new():addInstance( 'Particle' );

    local r, g, b, a, fade, sprite

    function self:update( dt )
        a = a - dt * fade;
    end

    function self:getColors()
        return r, g, b, a;
    end

    function self:getAlpha()
        return a;
    end

    function self:getSprite()
        return sprite;
    end

    function self:setParameters( nr, ng, nb, na, nfade, nsprite )
        r, g, b, a, fade, sprite = nr, ng, nb, na, nfade, nsprite
    end

    function self:clear()
        r, g, b, a, fade, sprite = nil, nil, nil, nil, nil, nil
    end

    return self;
end

return Particle;
