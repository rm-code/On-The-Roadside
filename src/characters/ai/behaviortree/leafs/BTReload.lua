---
-- @module BTReload
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )
local Reload = require( 'src.characters.actions.Reload' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTReload = BTLeaf:subclass( 'BTReload' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTReload:traverse( ... )
    local _, character = ...

    local success = character:enqueueAction( Reload( character ))
    if success then
        Log.debug( 'Reloading weapon', 'BTReload' )
        return true
    end

    Log.debug( 'Can not reload weapon', 'BTReload' )
    return false
end

return BTReload
