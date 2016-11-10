local Weapon = require( 'src.items.weapons.Weapon' );
local AmmunitionEffects = require( 'src.items.weapons.AmmunitionEffects' );

local ThrownWeapon = {};

function ThrownWeapon.new( template )
    local self = Weapon.new( template ):addInstance( 'ThrownWeapon' );

    local effects = AmmunitionEffects.new( template.effects );

    function self:getEffects()
        return effects;
    end

    function self:getRange()
        return template.range;
    end

    return self;
end

return ThrownWeapon;
