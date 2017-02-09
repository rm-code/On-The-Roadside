local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasWeapon = {};

function BTHasWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasWeapon' );

    function self:traverse( ... )
        Log.info( 'BTHasWeapon' );
        local _, character = ...;

        if character:getWeapon() then
            Log.info( 'Character has a weapon.' );
            return true;
        end

        return false;
    end

    return self;
end

return BTHasWeapon;
