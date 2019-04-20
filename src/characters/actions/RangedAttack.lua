---
-- @module RangedAttack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local ProjectileQueue = require( 'src.items.weapons.ProjectileQueue' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local RangedAttack = Action:subclass( 'RangedAttack' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function RangedAttack:initialize( character, target, projectileManager )
    Action.initialize( self, character, target, character:getWeapon():getAttackCost() )

    self.projectileManager = projectileManager
end

function RangedAttack:perform()
    -- Stop if the character's weapon is empty.
    if self.character:getWeapon():isEmpty() then
        return false
    end

    local tx, ty = self.target:getPosition()
    local th = self.target:getHeight()

    self.projectileManager:register( ProjectileQueue( self.character, tx, ty, th ))
    return true
end

return RangedAttack
