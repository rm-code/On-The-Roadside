local Weapon = require( 'src.items.weapons.Weapon' );

local MeleeWeapon = {};

function MeleeWeapon.new( template )
    local self = Weapon.new( template ):addInstance( 'MeleeWeapon' );

    return self;
end

return MeleeWeapon;
