local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasRangedWeapon = {};

function BTHasRangedWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasRangedWeapon' );

    function self:traverse( ... )
        print( 'BTHasRangedWeapon' );
        local _, character = ...;

        local type = character:getWeapon():getWeaponType();
        if type ~= 'Melee' and type ~= 'Thrown' then
            print( 'Character has a ranged weapon.' )
            return true;
        end

        return false;
    end

    return self;
end

return BTHasRangedWeapon;
