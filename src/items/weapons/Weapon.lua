---
-- @module Weapon
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Item = require( 'src.items.Item' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Weapon = Item:subclass( 'Weapon' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Weapon:initialize( template )
    Item.initialize( self, template )

    self.damage = template.damage
    self.reloadable = template.reloadable

    self.modes = template.mode
    self.mode = self.modes[1]
    self.modeIndex = 1

    self.sound = template.sound
end

function Weapon:selectNextFiringMode()
    self.modeIndex = self.modeIndex + 1 > #self.modes and 1 or self.modeIndex + 1
    self.mode = self.modes[self.modeIndex]
end

function Weapon:selectPrevFiringMode()
    self.modeIndex = self.modeIndex - 1 < 1 and #self.modes or self.modeIndex - 1
    self.mode = self.modes[self.modeIndex]
end

function Weapon:serialize()
    local t = Weapon.super.serialize( self )
    t['modeIndex'] = self.modeIndex
    return t
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function Weapon:getAccuracy()
    return self.mode.accuracy
end

function Weapon:getAttackCost()
    return self.mode.cost
end

function Weapon:getDamage()
    return self.damage
end

function Weapon:getAttackMode()
    return self.mode
end

function Weapon:getAttacks()
    return self.mode.attacks
end

function Weapon:getAttackModeIndex()
    return self.modeIndex
end

function Weapon:getSound()
    return self.sound
end

function Weapon:isReloadable()
    return self.reloadable
end

function Weapon:getModes()
    return self.modes
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function Weapon:setAttackMode( modeIndex )
    self.modeIndex = modeIndex
    self.mode = self.modes[self.modeIndex]
end

return Weapon
