---
-- @module BTThrowingAttack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )
local ThrowingAttack = require( 'src.characters.actions.ThrowingAttack' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTThrowingAttack = BTLeaf:subclass( 'BTThrowingAttack' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTThrowingAttack:traverse( ... )
    local blackboard, character, _, _, projectileManager = ...

    local success = character:enqueueAction( ThrowingAttack( character, blackboard.target, projectileManager ))
    if success then
        -- Store weapon id for the rearm action.
        blackboard.weaponID = character:getWeapon():getID()
        Log.debug( 'Character attacks target', 'BTThrowingAttack' )
        return true
    end

    Log.debug( 'Character can not attack target', 'BTThrowingAttack' )
    return false
end

return BTThrowingAttack
