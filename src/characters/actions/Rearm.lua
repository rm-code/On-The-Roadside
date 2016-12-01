local Action = require('src.characters.actions.Action');

local Rearm = {};

function Rearm.new( character, weaponID )
    local self = Action.new( 0, character:getTile() ):addInstance( 'Rearm' );

    function self:perform()
        local inventory = character:getInventory():getBackpack():getInventory();
        local weapon;

        for _, item in pairs( inventory:getItems() ) do
            if item:instanceOf( 'Weapon' ) and item:getID() == weaponID then
                weapon = item;
                break;
            elseif item:instanceOf( 'ItemStack' ) then
                for _, sitem in pairs( item:getItems() ) do
                    if sitem:instanceOf( 'Weapon' ) and sitem:getID() == weaponID then
                        weapon = sitem;
                        break;
                    end
                end
            end
        end

        if not weapon then
            return false;
        end

        -- Remove item from backpack and add it to the equipment slot.
        inventory:removeItem( weapon );
        character:getInventory():addItem( weapon );

        return true;
    end

    return self;
end

return Rearm;
