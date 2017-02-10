local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasThrowingWeapon = {};

local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

function BTHasThrowingWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasThrowingWeapon' );

    function self:traverse( ... )
        local _, character = ...;

        local result = character:getWeapon():getWeaponType() == WEAPON_TYPES.THROWN;
        Log.debug( result, 'BTHasThrowingWeapon' );
        return result;
    end

    return self;
end

return BTHasThrowingWeapon;
