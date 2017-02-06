local State = require( 'src.turnbased.states.State' );
local Attack = require( 'src.characters.actions.Attack' );
local MeleeAttack = require( 'src.characters.actions.MeleeAttack' );
local ThrowingAttack = require( 'src.characters.actions.ThrowingAttack' );
local Rearm = require( 'src.characters.actions.Rearm' );

local AttackInput = {};

function AttackInput.new()
    local self = State.new():addInstance( 'AttackInput' );

    local function generateAttack( target, character )
        character:enqueueAction( Attack.new( character, target ));
    end

    function self:request( ... )
        local target, character = ...;

        -- Prevent characters from attacking themselves.
        if target == character:getTile() then
            return false;
        end

        local weapon = character:getWeapon();
        if not weapon then
            return false;
        end

        if weapon:getWeaponType() == 'Melee' then
            character:enqueueAction( MeleeAttack.new( character, target ));
            return true;
        end

        if weapon:getWeaponType() == 'Thrown' then
            character:enqueueAction( ThrowingAttack.new( character, target ));
            character:enqueueAction( Rearm.new( character, weapon:getID() ));
            return true;
        end

        generateAttack( target, character );
        return true;
    end

    return self;
end

return AttackInput;
