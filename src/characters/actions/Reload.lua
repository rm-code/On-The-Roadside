local Action = require('src.characters.actions.Action');

local Reload = {};

function Reload.new( character )
    local self = Action.new( 5, character:getTile() ):addInstance( 'Reload' );

    function self:perform()
        local weapon = character:getEquipment():getWeapon();

        local inventory = character:getEquipment():getBackpack():getInventory();
        local magazine;
        for _, item in pairs( inventory:getItems() ) do
            if item:instanceOf( 'Magazine' ) and item:getAmmoType() == weapon:getAmmoType() then
                magazine = item;
                inventory:removeItem( item );
            end
        end
        weapon:reload( magazine );
    end

    return self;
end

return Reload;
