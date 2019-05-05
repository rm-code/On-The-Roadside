---
-- @module ThrownWeapon
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Weapon = require( 'src.items.weapons.Weapon' )
local AmmunitionEffects = require( 'src.items.weapons.AmmunitionEffects' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ThrownWeapon = Weapon:subclass( 'ThrownWeapon' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function ThrownWeapon:initialize( template )
    Weapon.initialize( self, template )

    self.effects = AmmunitionEffects( template.effects )
end

function ThrownWeapon:getDamageType()
    return self:getAttackMode().damageType
end

function ThrownWeapon:getAreaOfEffectRadius()
    return self:getAttackMode().areaOfEffectRadius
end

function ThrownWeapon:getEffects()
    return self.effects
end

return ThrownWeapon
