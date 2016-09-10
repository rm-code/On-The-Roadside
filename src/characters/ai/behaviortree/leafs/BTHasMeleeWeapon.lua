local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasMeleeWeapon = {};

function BTHasMeleeWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasMeleeWeapon' );

    function self:traverse( ... )
        print( 'BTHasMeleeWeapon' );
        local _, character = ...;

        if character:getEquipment():getWeapon():getWeaponType() == 'Melee' then
            print( 'Character has a melee weapon.' );
            return true;
        end

        return false;
    end

    return self;
end

return BTHasMeleeWeapon;
