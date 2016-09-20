local Action = require('src.characters.actions.Action');
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ProjectileQueue = require( 'src.items.weapons.ProjectileQueue' );
local Messenger = require( 'src.Messenger' );

local Attack = {};

function Attack.new( character, target )
    local self = Action.new( character:getInventory():getWeapon():getAttackCost(), target ):addInstance( 'Attack' );

    function self:perform()
        if character:getInventory():getWeapon():getMagazine():isEmpty() then
            return false;
        end

        Messenger.publish( 'START_ATTACK', target );
        local package = ProjectileQueue.new( character, target );
        ProjectileManager.register( package );
        return true;
    end

    return self;
end

return Attack;
