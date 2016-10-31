local Object = require( 'src.Object' );

local AmmunitionEffects = {};

function AmmunitionEffects.new( template )
    local self = Object.new():addInstance( 'AmmunitionEffects' );

    -- ------------------------------------------------
    -- Explosive Ammunition
    -- ------------------------------------------------

    function self:isExplosive()
        return template.explosive;
    end

    function self:getBlastRadius()
        return template.explosive.blastRadius;
    end

    -- ------------------------------------------------
    -- Ammunition that spreads on shot
    -- ------------------------------------------------

    function self:spreadsOnShot()
        return template.spreadsOnShot;
    end

    function self:getPellets()
        return template.spreadsOnShot.pellets;
    end

    -- ------------------------------------------------
    -- Ammunition has custom sprite
    -- ------------------------------------------------

    function self:hasCustomSprite()
        return template.customSprite;
    end

    function self:getCustomSprite()
        return template.customSprite.sprite;
    end

    return self;
end

return AmmunitionEffects;
