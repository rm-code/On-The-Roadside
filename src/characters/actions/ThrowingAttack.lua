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
    self.projectileManager:register( ThrownProjectileQueue( self.character, self.target ))
    return true
end

return ThrowingAttack
