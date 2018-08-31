---
-- @module BTAttackTarget
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )
local RangedAttack = require( 'src.characters.actions.RangedAttack' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTAttackTarget = BTLeaf:subclass( 'BTAttackTarget' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTAttackTarget:traverse( ... )
    local blackboard, character, _, _, projectileManager = ...

    local success = character:enqueueAction( RangedAttack( character, blackboard.target, projectileManager ))
    if success then
        Log.debug( 'Character attacks target', 'BTAttackTarget' )
        return true
    end

    Log.debug( 'Character can not attack target', 'BTAttackTarget' )
    return false
end

return BTAttackTarget
