---
-- @module ThrowingAttack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local ThrownProjectileQueue = require( 'src.items.weapons.ThrownProjectileQueue' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ThrowingAttack = Action:subclass( 'ThrowingAttack' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function ThrowingAttack:initialize( character, target, projectileManager )
    Action.initialize( self, character, target, character:getWeapon():getAttackCost() )

    self.projectileManager = projectileManager
end

function ThrowingAttack:perform()
    local tx, ty = self.target:getPosition()
    local th = self.target:getHeight()

    self.projectileManager:register( ThrownProjectileQueue( self.character, tx, ty, th ))
    return true
end

return ThrowingAttack
