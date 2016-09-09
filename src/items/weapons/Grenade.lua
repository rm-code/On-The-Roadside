local Weapon = require( 'src.items.weapons.Weapon' );

local Grenade = {};

function Grenade.new( template )
    local self = Weapon.new( template ):addInstance( 'Grenade' );

    return self;
end

return Grenade;
