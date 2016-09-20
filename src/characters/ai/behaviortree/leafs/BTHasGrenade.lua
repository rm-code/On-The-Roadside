local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasGrenade = {};

function BTHasGrenade.new()
    local self = BTLeaf.new():addInstance( 'BTHasGrenade' );

    function self:traverse( ... )
        print( 'BTHasGrenade' );
        local _, character = ...;

        if character:getInventory():getWeapon():getWeaponType() == 'Grenade' then
            return true;
        end

        return false;
    end

    return self;
end

return BTHasGrenade;
