local Object = require( 'src.Object' );

local BTComposite = {};

function BTComposite.new()
    local self = Object.new():addInstance( 'BTComposite' );

    local children = {};

    function self:addNode( nnode )
        children[#children + 1] = nnode;
    end

    function self:traverse( ... )
        for _, child in ipairs( children ) do
            local success = child:traverse( ... );
            if not success then
                return false;
            end
        end
        return true;
    end

    function self:getChildren()
        return children;
    end

    return self;
end

return BTComposite;
