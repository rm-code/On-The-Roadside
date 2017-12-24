---
-- @module BTSelector
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local BTComposite = require( 'src.characters.ai.behaviortree.composite.BTComposite' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTSelector = BTComposite:subclass( 'BTSelector' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTSelector:traverse( ... )
    for _, child in ipairs( self:getChildren() ) do
        local success = child:traverse( ... )
        if success then
            return true
        end
    end
    return false
end

return BTSelector
