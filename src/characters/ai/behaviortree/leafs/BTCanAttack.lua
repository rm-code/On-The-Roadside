---
-- @module BTCanAttack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTCanAttack = BTLeaf:subclass( 'BTCanAttack' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTCanAttack:traverse( ... )
    local _, character = ...

    local result = not character:getWeapon():isEmpty()
    Log.debug( result, 'BTCanAttack' )
    return result
end

return BTCanAttack
