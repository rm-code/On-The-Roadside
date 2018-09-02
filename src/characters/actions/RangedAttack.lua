---
-- @module RangedAttack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local ProjectileQueue = require( 'src.items.weapons.ProjectileQueue' )
local Bresenham = require( 'lib.Bresenham' )

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
    if self.character:getWeapon():getMagazine():isEmpty() then
        return false
    end

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

    self.projectileManager:register( ProjectileQueue( self.character, ax, ay, th ))
    return true
end

return RangedAttack
