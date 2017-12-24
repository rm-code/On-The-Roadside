---
-- @module Container
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Item = require( 'src.items.Item' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Container = Item:subclass( 'Container' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Container:initialize( template )
    Item.initialize( self, template )

    self.carryCapacity = template.carryCapacity
end

function Container:getCarryCapacity()
    return self.carryCapacity
end

return Container
