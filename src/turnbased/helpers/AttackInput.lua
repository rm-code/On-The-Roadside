local Object = require( 'src.Object' );
local Attack = require( 'src.characters.actions.Attack' );
local MeleeAttack = require( 'src.characters.actions.MeleeAttack' );
local ThrowingAttack = require( 'src.characters.actions.ThrowingAttack' );
local Rearm = require( 'src.characters.actions.Rearm' );

local AttackInput = {};

function AttackInput.new( stateManager )
    local self = Object.new():addInstance( 'AttackInput' );

    local function generateAttack( target, character )
        character:enqueueAction( Attack.new( character, target ));
    end

    function self:request( ... )
        local target, character = ...;

        -- Prevent characters from attacking themselves.
        if target == character:getTile() then
            return;
        end

        local weapon = character:getWeapon();
        if not weapon then
            return;
        end

        if weapon:getWeaponType() == 'Melee' then
            character:enqueueAction( MeleeAttack.new( character, target ));
            stateManager:push( 'execution', character );
            return;
        end

        if weapon:getWeaponType() == 'Thrown' then
            character:enqueueAction( ThrowingAttack.new( character, target ));
            character:enqueueAction( Rearm.new( character, weapon:getID() ));
            stateManager:push( 'execution', character );
            return;
        end

        generateAttack( target, character );
        stateManager:push( 'execution', character );
        return;
    end

    return self;
end

return AttackInput;
