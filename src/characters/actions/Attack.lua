local Action = require('src.characters.actions.Action');
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ProjectileQueue = require( 'src.items.weapons.ProjectileQueue' );

local Attack = {};

function Attack.new( character, target )
    local self = Action.new( character:getEquipment():getWeapon():getAttackCost(), target ):addInstance( 'Attack' );

    function self:perform()
        if character:getEquipment():getWeapon():getMagazine():isEmpty() then
            return false;
        end

        local package = ProjectileQueue.new( character, target );
        ProjectileManager.register( package );
        return true;
    end

    return self;
end

return Attack;
