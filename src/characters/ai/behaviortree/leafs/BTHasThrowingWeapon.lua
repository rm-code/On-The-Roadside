local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasThrowingWeapon = {};

function BTHasThrowingWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasThrowingWeapon' );

    function self:traverse( ... )
        print( 'BTHasThrowingWeapon' );
        local _, character = ...;

        if character:getWeapon():getWeaponType() == 'Thrown' then
            return true;
        end

        return false;
    end

    return self;
end

return BTHasThrowingWeapon;
