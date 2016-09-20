local Magazine = require( 'src.items.weapons.Magazine' );

local Rocket = {};

function Rocket.new( template )
    local self = Magazine.new( template ):addInstance( 'Rocket' );

    function self:getBlastRadius()
        return template.blastRadius;
    end

    return self;
end

return Rocket;
