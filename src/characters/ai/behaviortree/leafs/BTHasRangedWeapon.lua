local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasRangedWeapon = {};

local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

function BTHasRangedWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasRangedWeapon' );

    function self:traverse( ... )
        Log.info( 'BTHasRangedWeapon' );
        local _, character = ...;

        local type = character:getWeapon():getWeaponType();
        if type == WEAPON_TYPES.RANGED then
            Log.info( 'Character has a ranged weapon.' )
            return true;
        end

        return false;
    end

    return self;
end

return BTHasRangedWeapon;
