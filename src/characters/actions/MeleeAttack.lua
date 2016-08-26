local Action = require('src.characters.actions.Action');
local Messenger = require( 'src.Messenger' );

local MeleeAttack = {};

function MeleeAttack.new( character, target )
    local self = Action.new( character:getEquipment():getWeapon():getAttackCost(), target ):addInstance( 'MeleeAttack' );

    function self:perform()
        if not target:isAdjacent( character:getTile() ) then
            return false;
        end

        local weapon = character:getEquipment():getWeapon();
        Messenger.publish( 'SOUND_SHOOT', weapon );
        target:hit( weapon:getDamage() );
        return true;
    end

    return self;
end

return MeleeAttack;
