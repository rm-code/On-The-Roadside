local Magazine = require( 'src.items.weapons.Magazine' );

local ShotgunShell = {};

function ShotgunShell.new( caliber, itemType, ammoType, pellets )
    local self = Magazine.new( caliber, itemType, ammoType ):addInstance( 'ShotgunShell' );

    function self:getPelletAmount()
        return pellets;
    end

    return self;
end

return ShotgunShell;
