---
-- @module RangedWeapon
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Weapon = require( 'src.items.weapons.Weapon' )
local Magazine = require( 'src.items.weapons.Magazine' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local RangedWeapon = Weapon:subclass( 'RangedWeapon' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function RangedWeapon:initialize( template )
    Weapon.initialize( self, template )

    self.rpm = template.rpm or 60
    self.firingDelay = 1 / ( self.rpm / 60 )
    self.magazine = Magazine( template.caliber, template.magSize )
end

function RangedWeapon:serialize()
    local t = RangedWeapon.super.serialize( self )
    if self.magazine then
        t['magazine'] = self.magazine:serialize()
    end
    return t
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function RangedWeapon:getFiringDelay()
    return self.firingDelay
end

function RangedWeapon:getMagazine()
    return self.magazine
end

return RangedWeapon
