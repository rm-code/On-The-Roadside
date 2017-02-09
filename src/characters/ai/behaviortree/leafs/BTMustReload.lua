local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTMustReload = {};

function BTMustReload.new()
    local self = BTLeaf.new():addInstance( 'BTMustReload' );

    function self:traverse( ... )
        Log.info( 'BTMustReload' );
        local _, character = ...;

        if character:getWeapon():getMagazine():isEmpty() then
            Log.info( 'Magazine is empty -> We must reload!' );
            return true;
        end

        Log.info( 'Magazine is not empty -> We must not reload!' );

        return false;
    end

    return self;
end

return BTMustReload;
