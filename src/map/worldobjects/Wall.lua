local Object = require( 'src.Object' );

local Wall = {};

function Wall.new()
    local self = Object.new():addInstance( 'Wall' );

    function self:isPassable()
        return false;
    end

    return self;
end

return Wall;
