local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasMeleeWeapon = {};

local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

function BTHasMeleeWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasMeleeWeapon' );

    function self:traverse( ... )
        local _, character = ...;

        local result = character:getWeapon():getWeaponType() == WEAPON_TYPES.MELEE;
        Log.debug( result, 'BTHasMeleeWeapon' );
        return result;
    end

    return self;
end

return BTHasMeleeWeapon;
