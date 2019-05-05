---
-- @module RangedWeapon
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Weapon = require( 'src.items.weapons.Weapon' )
local AmmunitionEffects = require( 'src.items.weapons.AmmunitionEffects' )

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

    self.maximumCapacity = template.rounds
    self.currentCapacity = self.maximumCapacity

    self.damageType = template.damageType
    self.areaOfEffectRadius = template.areaOfEffectRadius
    self.effects = AmmunitionEffects( template.effects )
end

function RangedWeapon:reload()
    self.currentCapacity = self.maximumCapacity
end

function RangedWeapon:removeRound()
    self.currentCapacity = self.currentCapacity - 1
end

function RangedWeapon:serialize()
    local t = RangedWeapon.super.serialize( self )
    t['currentCapacity'] = self.currentCapacity
    return t
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function RangedWeapon:getFiringDelay()
    return self.firingDelay
end

---
-- Gets the magazine's maximum capacity.
-- @treturn number The number of rounds the magazine can hold.
--
function RangedWeapon:getMaximumCapacity()
    return self.maximumCapacity
end

---
-- Gets the current number of rounds.
-- @treturn number The current amount of rounds inside of the mag.
--
function RangedWeapon:getCurrentCapacity()
    return self.currentCapacity
end

---
-- Checks if the magazine is at full capacity.
-- @treturn boolean True if the magazine is full.
--
function RangedWeapon:isFull()
    return self.currentCapacity == self.maximumCapacity
end

---
-- Checks if the magazine is empty.
-- @treturn boolean True if the magazine is empty.
--
function RangedWeapon:isEmpty()
    return self.currentCapacity == 0
end

-- TODO integrate into weapon.lua like melee weapons
function RangedWeapon:getDamageType()
    return self.damageType
end

function RangedWeapon:getAreaOfEffectRadius()
    return self.areaOfEffectRadius
end

function RangedWeapon:getEffects()
    return self.effects
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Sets the current number of rounds.
-- @tparam rounds number The current amount of rounds inside of the mag.
--
function RangedWeapon:setCurrentCapacity( rounds )
    self.currentCapacity = rounds
end

return RangedWeapon
