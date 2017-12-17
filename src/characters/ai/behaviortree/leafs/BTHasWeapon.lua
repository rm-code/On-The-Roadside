---
-- @module BTHasWeapon
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTHasWeapon = BTLeaf:subclass( 'BTHasWeapon' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTHasWeapon:traverse( ... )
    local _, character = ...

    local result = character:getWeapon() ~= nil
    Log.debug( result, 'BTHasWeapon' )
    return result
end

return BTHasWeapon
