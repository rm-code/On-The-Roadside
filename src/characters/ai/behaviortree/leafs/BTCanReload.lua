---
-- @module BTCanReload
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTCanReload = BTLeaf:subclass( 'BTCanReload' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTCanReload:traverse()
    -- Characters can always reload.
    return true
end

return BTCanReload
