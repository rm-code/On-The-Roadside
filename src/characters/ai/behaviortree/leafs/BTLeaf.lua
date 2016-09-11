local Object = require( 'src.Object' );

local BTLeaf = {};

function BTLeaf.new()
    local self = Object.new():addInstance( 'BTLeaf' );

    function self:traverse()
        return true;
    end

    return self;
end

return BTLeaf;
