local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasWeapon = {};

function BTHasWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasWeapon' );

    function self:traverse( ... )
        print( 'BTHasWeapon' );
        local _, character = ...;

        if character:getInventory():getWeapon() then
            print( 'Character has a weapon.' );
            return true;
        end

        return false;
    end

    return self;
end

return BTHasWeapon;
