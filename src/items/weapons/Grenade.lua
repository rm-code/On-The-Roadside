local Weapon = require( 'src.items.weapons.Weapon' );

local Grenade = {};

function Grenade.new( template )
    local self = Weapon.new( template ):addInstance( 'Grenade' );

    function self:getFiringDelay()
        return 1;
    end

    return self;
end

return Grenade;
