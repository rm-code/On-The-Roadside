local Magazine = require( 'src.items.weapons.Magazine' );

local ShotgunShell = {};

function ShotgunShell.new( template )
    local self = Magazine.new( template ):addInstance( 'ShotgunShell' );

    function self:getPelletAmount()
        return template.pellets;
    end

    return self;
end

return ShotgunShell;
