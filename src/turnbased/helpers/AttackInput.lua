local Object = require( 'src.Object' );
local Attack = require( 'src.characters.actions.Attack' );
local MeleeAttack = require( 'src.characters.actions.MeleeAttack' );

local AttackInput = {};

function AttackInput.new( stateManager )
    local self = Object.new():addInstance( 'AttackInput' );

    local function generateAttack( target, character )
        character:enqueueAction( Attack.new( character, target ));
    end

    function self:request( ... )
        local target, character = unpack{ ... };

        if character:getEquipment():getWeapon():getWeaponType() == 'Melee' then
            character:enqueueAction( MeleeAttack.new( character, target ));
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
