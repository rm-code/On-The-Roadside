local Item = require( 'src.items.Item' );
local AmmunitionEffects = require( 'src.items.weapons.AmmunitionEffects' );

local Ammunition = {};

function Ammunition.new( template )
    local self = Item.new( template ):addInstance( 'Ammunition' );

    local effects = AmmunitionEffects.new( template.effects );

    function self:getDamageType()
        return template.damageType;
    end

    -- TODO: Add caliber to templates.
    function self:getCaliber()
        return template.id;
    end

    function self:getEffects()
        return effects;
    end

    return self;
end

return Ammunition;
