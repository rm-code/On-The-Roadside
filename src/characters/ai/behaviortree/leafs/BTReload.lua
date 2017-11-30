local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local Reload = require( 'src.characters.actions.Reload' );

local BTReload = {};

function BTReload.new()
    local self = BTLeaf.new():addInstance( 'BTReload' );

    function self:traverse( ... )
        local _, character = ...;

        local success = character:enqueueAction( Reload( character ))
        if success then
            Log.debug( 'Reloading weapon', 'BTReload' );
            return true;
        end

        Log.debug( 'Can not reload weapon', 'BTReload' );
        return false;
    end

    return self;
end

return BTReload;
