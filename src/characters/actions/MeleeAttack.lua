---
-- @module MeleeAttack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local Messenger = require( 'src.Messenger' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MeleeAttack = Action:subclass( 'MeleeAttack' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function MeleeAttack:initialize( character, target )
    Action.initialize( self, character, target, character:getWeapon():getAttackCost() )
end

function MeleeAttack:perform()
    if not self.target:isAdjacent( self.character:getTile() ) then
        return false
    end

    local weapon = self.character:getWeapon()
    self.target:hit( weapon:getDamage(), weapon:getDamageType() )

    Messenger.publish( 'SOUND_ATTACK', weapon )
    return true
end

return MeleeAttack
