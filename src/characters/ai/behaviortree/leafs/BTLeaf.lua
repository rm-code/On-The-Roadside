---
-- The base class for all behavior tree leafs.
-- @module BTLeaf
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTLeaf = Class( 'BTLeaf' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTLeaf:traverse()
    return true
end

return BTLeaf
