local Object = require( 'src.Object' );

local Equipment = {};

local ITEM_TYPES = require('src.constants.ItemTypes');
local CLOTHING_SLOTS = require('src.constants.ClothingSlots');

function Equipment.new()
    local self = Object.new():addInstance( 'Equipment' );

    local items = {
        [ITEM_TYPES.WEAPON] = true,
        [ITEM_TYPES.BAG] = true,
        [ITEM_TYPES.CLOTHING] = {
            [CLOTHING_SLOTS.HEADGEAR] = true,
            [CLOTHING_SLOTS.GLOVES] = true,
            [CLOTHING_SLOTS.JACKET] = true,
            [CLOTHING_SLOTS.SHIRT] = true,
            [CLOTHING_SLOTS.TROUSERS] = true,
            [CLOTHING_SLOTS.FOOTWEAR] = true
        }
    };

    function self:addItem( item )
        local main = item:getItemType();
        local sub  = item:getSubType();

        if sub then
            items[main][sub] = item;
            return;
        end

        items[main] = item;
    end

    function self:removeItem( item )
        local main = item:getItemType();
        local sub  = item:getSubType();
        local tmp;

        if sub then
            tmp = items[main][sub];
            items[main][sub] = nil;
            return tmp;
        end

        tmp = items[main];
        items[main] = nil;

        return tmp;
    end

    function self:containsItem( item )
        local main = item:getItemType();
        local sub  = item:getSubType();

        if sub then
            return items[main][sub] ~= nil;
        end

        return items[main] ~= nil;
    end

    function self:getWeapon()
        return items[ITEM_TYPES.WEAPON];
    end

    function self:getBackpack()
        return items[ITEM_TYPES.BAG];
    end

    function self:getClothingItem( part )
        return items[ITEM_TYPES.CLOTHING][part];
    end

    function self:getItems()
        return items;
    end

    return self;
end

return Equipment;
