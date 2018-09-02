---
-- @module AttackInput
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local RangedAttack = require( 'src.characters.actions.RangedAttack' )
local MeleeAttack = require( 'src.characters.actions.MeleeAttack' )
local ThrowingAttack = require( 'src.characters.actions.ThrowingAttack' )
local Rearm = require( 'src.characters.actions.Rearm' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local AttackInput = Class( 'AttackInput' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Requests a new action for a given character.
-- @tparam  Tile      target    The tile to act upon.
-- @tparam  Character character The character to create the action for.
-- @treturn boolean             True if an action was created, false otherwise.
--
function AttackInput:request( target, character, projectileManager )
    -- Prevent characters from attacking themselves.
    if target == character:getTile() then
        return false
    end

    local weapon = character:getWeapon()

    -- Characters can't attack with no weapon equipped.
    if not weapon then
        return false
    end

    -- Handle Melee weapons.
    if weapon:getSubType() == WEAPON_TYPES.MELEE then
        character:enqueueAction( MeleeAttack( character, target ))
    end

    -- Handle Thrown weapons.
    if weapon:getSubType() == WEAPON_TYPES.THROWN then
        character:enqueueAction( ThrowingAttack( character, target, projectileManager ))
        character:enqueueAction( Rearm( character, weapon:getID() ))
    end

    -- Handle Ranged weapons.
    if weapon:getSubType() == WEAPON_TYPES.RANGED then
        character:enqueueAction( RangedAttack( character, target, projectileManager ))
    end

    return true
end

---
-- Returns the predicted ap cost for this action.
-- @tparam  Character character The character taking the action.
-- @treturn number              The cost.
--
function AttackInput:getPredictedAPCost( character )
    if character:getWeapon() then
        return character:getWeapon():getAttackCost()
    end
end

return AttackInput
