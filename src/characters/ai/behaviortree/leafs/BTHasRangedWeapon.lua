---
-- @module BTHasRangedWeapon
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTHasRangedWeapon = BTLeaf:subclass( 'BTHasRangedWeapon' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTHasRangedWeapon:traverse( ... )
    local _, character = ...

    local result = character:getWeapon():getSubType() == WEAPON_TYPES.RANGED
    Log.debug( result, 'BTHasRangedWeapon' )
    return result
end

return BTHasRangedWeapon
