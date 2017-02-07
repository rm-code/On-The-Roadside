local State = require( 'src.turnbased.states.State' );
local Attack = require( 'src.characters.actions.Attack' );
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

local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

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
        if weapon:getWeaponType() == WEAPON_TYPES.MELEE then
            character:enqueueAction( MeleeAttack.new( character, target ));
        end

        -- Handle Thrown weapons.
        if weapon:getWeaponType() == WEAPON_TYPES.THROWN then
            character:enqueueAction( ThrowingAttack.new( character, target ));
            character:enqueueAction( Rearm.new( character, weapon:getID() ));
        end

        -- Handle Ranged weapons.
        if weapon:getWeaponType() == WEAPON_TYPES.RANGED then
            character:enqueueAction( Attack.new( character, target ));
        end

        return true;
    end

    return self;
end

return AttackInput;
