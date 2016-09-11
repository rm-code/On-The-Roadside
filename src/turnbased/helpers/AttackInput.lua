local Object = require( 'src.Object' );
local Attack = require( 'src.characters.actions.Attack' );
local MeleeAttack = require( 'src.characters.actions.MeleeAttack' );
local ThrowingAttack = require( 'src.characters.actions.ThrowingAttack' );

local AttackInput = {};

function AttackInput.new( stateManager )
    local self = Object.new():addInstance( 'AttackInput' );

    local function generateAttack( target, character )
        character:enqueueAction( Attack.new( character, target ));
    end

    function self:request( ... )
        local target, character = unpack{ ... };

        if not character:getEquipment():getWeapon() then
            return;
        end

        if character:getEquipment():getWeapon():getWeaponType() == 'Melee' then
            character:enqueueAction( MeleeAttack.new( character, target ));
            stateManager:push( 'execution', character );
            return;
        end

        if character:getEquipment():getWeapon():getWeaponType() == 'Grenade' then
            character:enqueueAction( ThrowingAttack.new( character, target ));
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
