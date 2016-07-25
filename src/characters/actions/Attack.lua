local Action = require('src.characters.actions.Action');
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ProjectileQueue = require( 'src.items.weapons.ProjectileQueue' );

local Attack = {};

function Attack.new( character, target )
    local self = Action.new( character:getEquipment():getWeapon():getAttackCost(), target ):addInstance( 'Attack' );

    function self:perform()
        local package = ProjectileQueue.new( character, target );
        ProjectileManager.register( package );
        character:removeLineOfSight();
    end

    return self;
end

return Attack;
