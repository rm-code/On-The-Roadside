local Object = require( 'src.Object' );

local Floor = {};

function Floor.new()
    local self = Object.new():addInstance( 'Floor' );

    function self:isPassable()
        return true;
    end

    function self:getType()
        return 'Floor';
    end

    return self;
end

return Floor;
