---
-- @module ThrowingAttack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local ThrownProjectileQueue = require( 'src.items.weapons.ThrownProjectileQueue' )
local Bresenham = require( 'lib.Bresenham' )

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
    -- Pick the actual target based on the weapon's range attribute.
    local ox, oy = self.character:getTile():getPosition()
    local tx, ty = self.target:getPosition()
    local th = self.target:getHeight()

    local ax, ay
    Bresenham.line( ox, oy, tx, ty, function( cx, cy, count )
        if count > self.character:getWeapon():getRange() then
            return false
        end
        ax, ay = cx, cy
        return true
    end)

    self.projectileManager:register( ThrownProjectileQueue( self.character, ax, ay, th ))
    return true
end

return ThrowingAttack
