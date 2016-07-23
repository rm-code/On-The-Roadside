local Object = require( 'src.Object' );
local StorageSlot = require( 'src.inventory.StorageSlot' );

local ITEM_TYPES = require('src.constants.ItemTypes');
local CLOTHING_SLOTS = require('src.constants.ClothingSlots');

local Inventory = {};

function Inventory.new()
    local self = Object.new():addInstance( 'Inventory' );

    local slots = {
        StorageSlot.new( ITEM_TYPES.WEAPON );
        StorageSlot.new( ITEM_TYPES.BAG );
        StorageSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.HEADGEAR );
        StorageSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.GLOVES   );
        StorageSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.JACKET   );
        StorageSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.SHIRT    );
        StorageSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.TROUSERS );
        StorageSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.FOOTWEAR );
    };

    function self:equipItem( item )
        for i = 1, #slots do
            local slot = slots[i];
            if slot:canEquip( item ) then
                slot:addItem( item );
            end
        end
    end

    function self:getPrimaryWeapon()
        return slots[1]:getItem();
    end

    function self:getClothingItem( type )
        for _, slot in ipairs( slots ) do
            if slot:getSubType() == type then
                return slot:getItem();
            end
        end
    end

    function self:getBackpack()
        return slots[2]:getItem();
    end

    function self:getSlots()
        return slots;
    end

    return self;
end

return Inventory;
