local Weapon = require( 'src.items.weapons.Weapon' );

local MeleeWeapon = {};

function MeleeWeapon.new( template )
    local self = Weapon.new( template ):addInstance( 'MeleeWeapon' );

    function self:getDamageType()
        return self:getAttackMode().damageType;
    end

    return self;
end

return MeleeWeapon;
