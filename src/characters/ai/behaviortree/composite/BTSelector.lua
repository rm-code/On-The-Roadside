local Log = require( 'src.util.Log' );
local BTComposite = require( 'src.characters.ai.behaviortree.composite.BTComposite' );

local BTSelector = {};

function BTSelector.new()
    local self = BTComposite.new():addInstance( 'BTSelector' );

    function self:traverse( ... )
        Log.info( 'BTSelector' );
        for _, child in ipairs( self:getChildren() ) do
            local success = child:traverse( ... );
            if success then
                return true;
            end
        end
        return false;
    end

    return self;
end

return BTSelector;
