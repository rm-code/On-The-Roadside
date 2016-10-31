local Action = require('src.characters.actions.Action');

local Reload = {};

function Reload.new( character )
    local self = Action.new( 5, character:getTile() ):addInstance( 'Reload' );

    local function reload( weapon, inventory, item )
        weapon:getMagazine():addRound( item );
        inventory:removeItem( item );
    end

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
        for _, item in pairs( inventory:getItems() ) do
            if item:instanceOf( 'Ammunition' ) and item:getCaliber() == weapon:getMagazine():getCaliber() then
                reload( weapon, inventory, item );
            elseif item:instanceOf( 'ItemStack' ) then
                for _, sitem in pairs( item:getItems() ) do
                    reload( weapon, inventory, sitem );
                    if weapon:getMagazine():isFull() then
                        break;
                    end
                end
            end
        end

        return true;
    end

    return self;
end

return Reload;
