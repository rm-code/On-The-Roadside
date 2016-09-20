local Action = require('src.characters.actions.Action');
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ProjectileQueue = require( 'src.items.weapons.ProjectileQueue' );
local Messenger = require( 'src.Messenger' );

local ThrowingAttack = {};

function ThrowingAttack.new( character, target )
    local self = Action.new( character:getInventory():getWeapon():getAttackCost(), target ):addInstance( 'ThrowingAttack' );

    function self:perform()
        Messenger.publish( 'START_ATTACK', target );
        local package = ProjectileQueue.new( character, target );
        ProjectileManager.register( package );
        return true;
    end

    return self;
end

return ThrowingAttack;
