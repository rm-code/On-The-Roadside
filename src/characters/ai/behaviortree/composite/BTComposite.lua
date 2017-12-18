---
-- @module BTComposite
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTComposite = Class( 'BTComposite' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTComposite:initialize()
    self.children = {}
end

function BTComposite:addNode( nnode, pos )
    self.children[pos] = nnode
end

function BTComposite:traverse( ... )
    for _, child in ipairs( self.children ) do
        local success = child:traverse( ... )
        if not success then
            return false
        end
    end
    return true
end

function BTComposite:getChildren()
    return self.children
end

return BTComposite
