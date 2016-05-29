local Object = require( 'src.Object' );
local EquipmentSlot = require( 'src.characters.inventory.EquipmentSlot' );

local Inventory = {};

function Inventory.new()
    local self = Object.new():addInstance( 'Inventory' );

    local primaryWeaponSlot = EquipmentSlot.new( 'Weapon' );

    local clothing = {
        ['Headgear'] = EquipmentSlot.new( 'Clothing' );
        ['Shirt']    = EquipmentSlot.new( 'Clothing' );
        ['Jacket']   = EquipmentSlot.new( 'Clothing' );
        ['Gloves']   = EquipmentSlot.new( 'Clothing' );
        ['Trousers'] = EquipmentSlot.new( 'Clothing' );
        ['Footwear'] = EquipmentSlot.new( 'Clothing' );
    }

    local function equipItem( slot, item )
        slot:setItem( item );
    end

    function self:equipPrimaryWeapon( weapon )
        primaryWeaponSlot:setItem( weapon );
    end

    function self:equipClothingItem( item )
        for type, slot in pairs( clothing ) do
            if type == item:getClothingType() then
                equipItem( slot, item );
                break;
            end
        end
    end

    function self:getPrimaryWeapon()
        return primaryWeaponSlot:getItem();
    end

    return self;
end

return Inventory;
