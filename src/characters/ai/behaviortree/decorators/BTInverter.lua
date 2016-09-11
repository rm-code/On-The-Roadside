local Object = require( 'src.Object' );

local BTInverter = {};

function BTInverter.new()
    local self = Object.new():addInstance( 'BTInverter' );

    local child;

    function self:addNode( nnode )
        child = nnode;
    end

    function self:traverse( ... )
        print( 'BTInverter' );
        return not child:traverse( ... );
    end

    return self;
end

return BTInverter;
