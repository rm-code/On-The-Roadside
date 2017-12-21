---
-- @module AmmunitionEffects
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local AmmunitionEffects = Class( 'AmmunitionEffects' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function AmmunitionEffects:initialize( template )
    self.template = template
end

-- ------------------------------------------------
-- Explosive Ammunition
-- ------------------------------------------------

function AmmunitionEffects:isExplosive()
    return self.template.explosive
end

function AmmunitionEffects:getBlastRadius()
    return self.template.explosive.blastRadius
end

-- ------------------------------------------------
-- Ammunition that spreads on shot
-- ------------------------------------------------

function AmmunitionEffects:spreadsOnShot()
    return self.template.spreadsOnShot
end

function AmmunitionEffects:getPellets()
    return self.template.spreadsOnShot.pellets
end

-- ------------------------------------------------
-- Ammunition with custom speed
-- ------------------------------------------------

function AmmunitionEffects:hasCustomSpeed()
    return self.template.customSpeed
end

function AmmunitionEffects:getCustomSpeed()
    return self.template.customSpeed.speed
end

function AmmunitionEffects:getSpeedIncrease()
    return self.template.customSpeed.increase or 0
end

function AmmunitionEffects:getFinalSpeed()
    return self.template.customSpeed.final or self.template.customSpeed.speed
end

-- ------------------------------------------------
-- Ammunition has custom sprite
-- ------------------------------------------------

function AmmunitionEffects:hasCustomSprite()
    return self.template.customSprite
end

function AmmunitionEffects:getCustomSprite()
    return self.template.customSprite.sprite
end

return AmmunitionEffects
