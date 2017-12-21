---
-- @module Ammunition
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Item = require( 'src.items.Item' )
local AmmunitionEffects = require( 'src.items.weapons.AmmunitionEffects' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Ammunition = Item:subclass( 'Ammunition' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Ammunition:initialize( template )
    Item.initialize( self, template )

    self.damageType = template.damageType
    self.effects = AmmunitionEffects( template.effects )
end

function Ammunition:getDamageType()
    return self.damageType
end

function Ammunition:getCaliber()
    return self.id
end

function Ammunition:getEffects()
    return self.effects
end

return Ammunition
