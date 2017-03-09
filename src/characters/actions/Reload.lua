local Log = require( 'src.util.Log' );
local Action = require('src.characters.actions.Action');

local Reload = {};

function Reload.new( character )
    local self = Action.new( 5, character:getTile() ):addInstance( 'Reload' );

    local function reload( weapon, inventory, item )
        weapon:getMagazine():addRound( item );
        inventory:removeItem( item );
    end

    function self:perform()
        local weapon = character:getWeapon();

        if not weapon or not weapon:isReloadable() then
            Log.debug( 'Can not reload.' );
            return false;
        end

        if weapon:getMagazine():isFull() then
            Log.debug( 'Weapon is fully loaded.' );
            return false;
        end

        local inventory = character:getInventory();
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
