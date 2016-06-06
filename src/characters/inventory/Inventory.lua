local Object = require( 'src.Object' );
local EquipmentSlot = require( 'src.characters.inventory.EquipmentSlot' );

local CLOTHING_SLOTS = require('src.constants.ClothingSlots');

local Inventory = {};

function Inventory.new()
    local self = Object.new():addInstance( 'Inventory' );

    local primaryWeaponSlot = EquipmentSlot.new( 'Weapon' );

    local clothing = {
        [CLOTHING_SLOTS.HEADGEAR] = EquipmentSlot.new( 'Clothing' );
        [CLOTHING_SLOTS.GLOVES  ] = EquipmentSlot.new( 'Clothing' );
        [CLOTHING_SLOTS.JACKET  ] = EquipmentSlot.new( 'Clothing' );
        [CLOTHING_SLOTS.SHIRT   ] = EquipmentSlot.new( 'Clothing' );
        [CLOTHING_SLOTS.TROUSERS] = EquipmentSlot.new( 'Clothing' );
        [CLOTHING_SLOTS.FOOTWEAR] = EquipmentSlot.new( 'Clothing' );
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
