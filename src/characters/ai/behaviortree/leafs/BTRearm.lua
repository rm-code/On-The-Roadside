---
-- @module BTRearm
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )
local Rearm = require( 'src.characters.actions.Rearm' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTRearm = BTLeaf:subclass( 'BTRearm' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTRearm:traverse( ... )
    local blackboard, character = ...

    local success = character:enqueueAction( Rearm( character, blackboard.weaponID ))
    if success then
        Log.debug( 'Equipping throwing weapon ' .. blackboard.weaponID, 'BTRearm' )
        return true
    end

    Log.debug( 'Equipping throwing weapon', 'BTRearm' )
    return false
end

return BTRearm
