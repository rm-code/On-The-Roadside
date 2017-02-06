local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasMeleeWeapon = {};

function BTHasMeleeWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasMeleeWeapon' );

    function self:traverse( ... )
        Log.info( 'BTHasMeleeWeapon' );
        local _, character = ...;

        if character:getWeapon():getWeaponType() == 'Melee' then
            Log.info( 'Character has a melee weapon.' );
            return true;
        end

        return false;
    end

    return self;
end

return BTHasMeleeWeapon;
