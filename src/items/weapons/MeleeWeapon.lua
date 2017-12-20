---
-- @module MeleeWeapon
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Weapon = require( 'src.items.weapons.Weapon' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MeleeWeapon = Weapon:subclass( 'MeleeWeapon' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function MeleeWeapon:initialize( template )
    Weapon.initialize( self, template )
end

function MeleeWeapon:getDamageType()
    return self:getAttackMode().damageType
end

return MeleeWeapon
