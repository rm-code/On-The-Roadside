---
-- @module BTHasThrowingWeapon
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTHasThrowingWeapon = BTLeaf:subclass( 'BTHasThrowingWeapon' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTHasThrowingWeapon:traverse( ... )
    local _, character = ...

    local result = character:getWeapon():getSubType() == WEAPON_TYPES.THROWN
    Log.debug( result, 'BTHasThrowingWeapon' )
    return result
end

return BTHasThrowingWeapon
