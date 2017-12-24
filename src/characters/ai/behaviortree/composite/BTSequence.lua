---
-- @module BTSequence
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local BTComposite = require( 'src.characters.ai.behaviortree.composite.BTComposite' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTSequence = BTComposite:subclass( 'BTSequence' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTSequence:traverse( ... )
    for _, child in ipairs( self:getChildren() ) do
        local success = child:traverse( ... )
        if not success then
            return false
        end
    end
    return true
end

return BTSequence
