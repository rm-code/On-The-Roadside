local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasThrowingWeapon = {};

local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

function BTHasThrowingWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasThrowingWeapon' );

    function self:traverse( ... )
        Log.info( 'BTHasThrowingWeapon' );
        local _, character = ...;

        if character:getWeapon():getWeaponType() == WEAPON_TYPES.THROWN then
            return true;
        end

        return false;
    end

    return self;
end

return BTHasThrowingWeapon;
