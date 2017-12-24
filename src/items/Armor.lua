---
-- @module Armor
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Item = require( 'src.items.Item' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Armor = Item:subclass( 'Armor' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Armor:initialize( template )
    Item.initialize( self, template )

    self.armorProtection = template.armor.protection
    self.armorCoverage = template.armor.coverage
end

function Armor:getArmorProtection()
    return self.armorProtection
end

function Armor:getArmorCoverage()
    return self.armorCoverage
end

return Armor
