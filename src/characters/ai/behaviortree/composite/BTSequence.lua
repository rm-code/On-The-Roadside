local BTComposite = require( 'src.characters.ai.behaviortree.composite.BTComposite' );

local BTSequence = {};

function BTSequence.new()
    local self = BTComposite.new():addInstance( 'BTSequence' );

    function self:traverse( ... )
        print( 'BTSequence' );
        for _, child in ipairs( self:getChildren() ) do
            local success = child:traverse( ... );
            print ( '=> ' .. tostring( success ));
            if not success then
                return false;
            end
        end
        return true;
    end

    return self;
end

return BTSequence;
