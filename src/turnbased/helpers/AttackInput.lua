local State = require( 'src.turnbased.states.State' );
local RangedAttack = require( 'src.characters.actions.RangedAttack' );
local MeleeAttack = require( 'src.characters.actions.MeleeAttack' );
local ThrowingAttack = require( 'src.characters.actions.ThrowingAttack' );
local Rearm = require( 'src.characters.actions.Rearm' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local AttackInput = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function AttackInput.new()
    local self = State.new():addInstance( 'AttackInput' );

    ---
    -- Requests a new action for a given character.
    -- @param target    (Tile)      The tile to act upon.
    -- @param character (Character) The character to create the action for.
    -- @return          (boolean)   True if an action was created, false otherwise.
    --
    function self:request( target, character )
        -- Prevent characters from attacking themselves.
        if target == character:getTile() then
            return false;
        end

        local weapon = character:getWeapon();

        -- Characters can't attack with no weapon equipped.
        if not weapon then
            return false;
        end

        -- Handle Melee weapons.
        if weapon:getSubType() == WEAPON_TYPES.MELEE then
            character:enqueueAction( MeleeAttack( character, target ))
        end

        -- Handle Thrown weapons.
        if weapon:getSubType() == WEAPON_TYPES.THROWN then
            character:enqueueAction( ThrowingAttack( character, target ))
            character:enqueueAction( Rearm( character, weapon:getID() ))
        end

        -- Handle Ranged weapons.
        if weapon:getSubType() == WEAPON_TYPES.RANGED then
            character:enqueueAction( RangedAttack( character, target ))
        end

        return true;
    end

    ---
    -- Returns the predicted ap cost for this action.
    -- @param character (Character) The character taking the action.
    -- @return          (number)    The cost.
    --
    function self:getPredictedAPCost( character )
        if character:getWeapon() then
            return character:getWeapon():getAttackCost();
        end
    end

    return self;
end

return AttackInput;
