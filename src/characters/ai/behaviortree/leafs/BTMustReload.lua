local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTMustReload = {};

function BTMustReload.new()
    local self = BTLeaf.new():addInstance( 'BTMustReload' );

    function self:traverse( ... )
        local _, character = ...;

        local result = character:getWeapon():getMagazine():isEmpty();
        Log.debug( result, 'BTMustReload' );
        return result;
    end

    return self;
end

return BTMustReload;
