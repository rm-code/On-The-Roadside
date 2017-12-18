---
-- @module BTMeleeAttack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )
local MeleeAttack = require( 'src.characters.actions.MeleeAttack' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTMeleeAttack = BTLeaf:subclass( 'BTMeleeAttack' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTMeleeAttack:traverse( ... )
    local blackboard, character = ...

    local success = character:enqueueAction( MeleeAttack( character, blackboard.target ))
    if success then
        Log.debug( 'Character attacks target', 'BTMeleeAttack' )
        return true
    end

    Log.debug( 'Character can not attack target', 'BTMeleeAttack' )
    return false
end

return BTMeleeAttack
