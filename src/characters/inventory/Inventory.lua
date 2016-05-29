local Object = require( 'src.Object' );
local EquipmentSlot = require( 'src.characters.inventory.EquipmentSlot' );

local ITEM_TYPES = require('src.constants.ItemTypes');
local CLOTHING_SLOTS = require('src.constants.ClothingSlots');

local Inventory = {};

function Inventory.new()
    local self = Object.new():addInstance( 'Inventory' );

    local primaryWeaponSlot = EquipmentSlot.new( ITEM_TYPES.WEAPON );
    local backpackSlot = EquipmentSlot.new( ITEM_TYPES.BAG );

    local clothing = {
        [CLOTHING_SLOTS.HEADGEAR] = EquipmentSlot.new( ITEM_TYPES.CLOTHING );
        [CLOTHING_SLOTS.GLOVES  ] = EquipmentSlot.new( ITEM_TYPES.CLOTHING );
        [CLOTHING_SLOTS.JACKET  ] = EquipmentSlot.new( ITEM_TYPES.CLOTHING );
        [CLOTHING_SLOTS.SHIRT   ] = EquipmentSlot.new( ITEM_TYPES.CLOTHING );
        [CLOTHING_SLOTS.TROUSERS] = EquipmentSlot.new( ITEM_TYPES.CLOTHING );
        [CLOTHING_SLOTS.FOOTWEAR] = EquipmentSlot.new( ITEM_TYPES.CLOTHING );
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

    function self:equipBackpack( item )
        backpackSlot:setItem( item );
    end

    function self:getClothing()
        return clothing;
    end

    function self:getPrimaryWeapon()
        return primaryWeaponSlot:getItem();
    end

    function self:getClothingItem( type )
        return clothing[type]:getItem();
    end

    function self:getBackpack()
        return backpackSlot:getItem();
    end

    return self;
end

return Inventory;
