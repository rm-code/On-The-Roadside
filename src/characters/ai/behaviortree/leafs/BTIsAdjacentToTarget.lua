---
-- @module BTIsAdjacentToTarget
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTIsAdjacentToTarget = BTLeaf:subclass( 'BTIsAdjacentToTarget' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTIsAdjacentToTarget:traverse( ... )
    local blackboard, character = ...

    local result = character:getTile():isAdjacent( blackboard.target )
    Log.debug( result, 'BTIsAdjacentToTarget' )
    return result
end

return BTIsAdjacentToTarget
