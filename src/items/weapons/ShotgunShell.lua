local Magazine = require( 'src.items.weapons.Magazine' );

local ShotgunShell = {};

function ShotgunShell.new( caliber, itemType, ammoType, capacity, pellets )
    local self = Magazine.new( caliber, itemType, ammoType, capacity ):addInstance( 'ShotgunShell' );

    function self:getPelletAmount()
        return pellets;
    end

    return self;
end

return ShotgunShell;
