local Action = require('src.characters.actions.Action');

local Reload = {};

function Reload.new( character )
    local self = Action.new( 5, character:getTile() ):addInstance( 'Reload' );

    function self:perform()
        local weapon = character:getInventory():getWeapon();

        if not weapon or weapon:getWeaponType() == 'Grenade' or weapon:getWeaponType() == 'Melee' then
            print( 'Can not reload.' );
            return false;
        end

        if weapon:getMagazine():isFull() then
            print( 'Weapon is fully loaded.' );
            return false;
        end

        local inventory = character:getInventory():getBackpack():getInventory();
        local magazine;
        for _, item in pairs( inventory:getItems() ) do
            if item:instanceOf( 'Magazine' ) and item:getCaliber() == weapon:getCaliber() then
                magazine = item;
                inventory:removeItem( item );
            end
        end

        if not magazine then
            print( 'No magazine found.' );
            return false;
        end

        weapon:reload( magazine );
        return true;
    end

    return self;
end

return Reload;
