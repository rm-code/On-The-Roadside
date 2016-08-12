local Magazine = require( 'src.items.weapons.Magazine' );

local Rocket = {};

function Rocket.new( caliber, itemType, ammoType, capacity, blastRadius )
    local self = Magazine.new( caliber, itemType, ammoType, capacity ):addInstance( 'Rocket' );

    function self:getBlastRadius()
        return blastRadius;
    end

    return self;
end

return Rocket;
