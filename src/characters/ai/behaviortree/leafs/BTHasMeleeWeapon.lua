---
-- @module BTHasMeleeWeapon
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTHasMeleeWeapon = BTLeaf:subclass( 'BTHasMeleeWeapon' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTHasMeleeWeapon:traverse( ... )
    local _, character = ...

    local result = character:getWeapon():getSubType() == WEAPON_TYPES.MELEE
    Log.debug( result, 'BTHasMeleeWeapon' )
    return result
end

return BTHasMeleeWeapon
