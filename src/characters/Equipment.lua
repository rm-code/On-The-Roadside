local Object = require( 'src.Object' );

local Equipment = {};

local ITEM_TYPES = require('src.constants.ItemTypes');

function Equipment.new()
    local self = Object.new():addInstance( 'Equipment' );

    local items = {
        [ITEM_TYPES.WEAPON]   = false,
        [ITEM_TYPES.BAG]      = false,
        [ITEM_TYPES.HEADGEAR] = false,
        [ITEM_TYPES.GLOVES]   = false,
        [ITEM_TYPES.JACKET]   = false,
        [ITEM_TYPES.SHIRT]    = false,
        [ITEM_TYPES.TROUSERS] = false,
        [ITEM_TYPES.FOOTWEAR] = false
    };

    function self:addItem( item )
        local main = item:getItemType();
        items[main] = item;
    end

    function self:clear()
        items[ITEM_TYPES.WEAPON]   = false;
        items[ITEM_TYPES.BAG]      = false;
        items[ITEM_TYPES.HEADGEAR] = false;
        items[ITEM_TYPES.GLOVES]   = false;
        items[ITEM_TYPES.JACKET]   = false;
        items[ITEM_TYPES.SHIRT]    = false;
        items[ITEM_TYPES.TROUSERS] = false;
        items[ITEM_TYPES.FOOTWEAR] = false;
    end

    function self:removeItem( item )
        local main = item:getItemType();
        local tmp = items[main];
        items[main] = nil;
        return tmp;
    end

    function self:containsItem( item )
        local main = item:getItemType();
        return items[main] ~= nil;
    end

    function self:getWeapon()
        return items[ITEM_TYPES.WEAPON];
    end

    function self:getBackpack()
        return items[ITEM_TYPES.BAG];
    end

    function self:getClothingItem( part )
        return items[part];
    end

    function self:getItems()
        return items;
    end

    return self;
end

return Equipment;
