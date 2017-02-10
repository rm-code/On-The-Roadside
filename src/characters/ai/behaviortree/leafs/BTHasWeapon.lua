local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasWeapon = {};

function BTHasWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasWeapon' );

    function self:traverse( ... )
        local _, character = ...;

        local result = character:getWeapon() ~= nil;
        Log.debug( result, 'BTHasWeapon' );
        return result;
    end

    return self;
end

return BTHasWeapon;
