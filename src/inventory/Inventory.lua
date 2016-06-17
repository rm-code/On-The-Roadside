local Object = require( 'src.Object' );
local StorageSlot = require( 'src.inventory.StorageSlot' );
local ClothingSlot = require( 'src.inventory.ClothingSlot' );

local ITEM_TYPES = require('src.constants.ItemTypes');
local CLOTHING_SLOTS = require('src.constants.ClothingSlots');

local Inventory = {};

function Inventory.new()
    local self = Object.new():addInstance( 'Inventory' );

    local slots = {
        StorageSlot.new( ITEM_TYPES.WEAPON );
        StorageSlot.new( ITEM_TYPES.BAG );
        ClothingSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.HEADGEAR );
        ClothingSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.GLOVES   );
        ClothingSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.JACKET   );
        ClothingSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.SHIRT    );
        ClothingSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.TROUSERS );
        ClothingSlot.new( ITEM_TYPES.CLOTHING, CLOTHING_SLOTS.FOOTWEAR );
    };

    function self:equipItem( item )
        for i = 1, #slots do
            local slot = slots[i];
            if slot:getItemType() == item:getItemType() then
                if item:getItemType() == ITEM_TYPES.CLOTHING then
                    if slot:instanceOf( 'ClothingSlot' ) and slot:getClothingType() == item:getClothingType() then
                        slot:addItem( item );
                        break;
                    end
                else
                    slot:addItem( item );
                    break;
                end
            end
        end
    end

    function self:getPrimaryWeapon()
        return slots[1]:getItem();
    end

    function self:getClothingItem( type )
        for _, slot in ipairs( slots ) do
            if slot:instanceOf( 'ClothingSlot' ) and slot:getClothingType() == type then
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
