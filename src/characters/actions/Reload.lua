local Action = require('src.characters.actions.Action');
local ItemFactory = require('src.items.ItemFactory');

local Reload = {};

function Reload.new( character )
    local self = Action.new( 5 ):addInstance( 'Reload' );

    function self:perform()
        local weapon = character:getWeapon();
        local magazine = ItemFactory.createMagazine( weapon:getAmmoType(), 30 );
        weapon:reload( magazine );
    end

    return self;
end

return Reload;
