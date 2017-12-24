---
-- @module RangedAttack
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' )
local ProjectileQueue = require( 'src.items.weapons.ProjectileQueue' )
local Bresenham = require( 'lib.Bresenham' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local RangedAttack = Action:subclass( 'RangedAttack' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function RangedAttack:initialize( character, target )
    Action.initialize( self, character, target, character:getWeapon():getAttackCost() )
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

    local package = ProjectileQueue( self.character, ax, ay, th )
    ProjectileManager.register( package )
    return true
end

return RangedAttack
