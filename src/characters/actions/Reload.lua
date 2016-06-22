local Action = require('src.characters.actions.Action');
local ItemFactory = require('src.items.ItemFactory');

local Attack = {};

function Attack.new( character )
    local self = Action.new( 5 ):addInstance( 'Attack' );

    function self:perform()
        local weapon = character:getWeapon();
        local magazine = ItemFactory.createMagazine( weapon:getAmmoType(), 30 );
        weapon:reload( magazine );
    end

    return self;
end

return Attack;
