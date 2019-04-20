---
-- @module BTMustReload
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTMustReload = BTLeaf:subclass( 'BTMustReload' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTMustReload:traverse( ... )
    local _, character = ...

    local result = character:getWeapon():isEmpty()
    Log.debug( result, 'BTMustReload' )
    return result
end

return BTMustReload
