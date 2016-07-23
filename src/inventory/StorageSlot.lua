local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local StorageSlot = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require( 'src.constants.ItemTypes' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function StorageSlot.new( itemType, subType )
    local self = Object.new():addInstance( 'StorageSlot' );

    itemType = itemType or ITEM_TYPES.UNIVERSAL;

    local item;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:addItem( nitem )
        item = nitem;
    end

    function self:removeItem()
        item = nil;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:canEquip( nitem )
        -- Universal slots can equip everything.
        if itemType == ITEM_TYPES.UNIVERSAL then
            return true;
        end

        -- Specific item slots can equip items.
        if itemType == nitem:getItemType() and subType == nitem:getSubType() then
            return true;
        end
    end

    function self:getItem()
        return item;
    end

    function self:getItemType()
        return itemType;
    end

    function self:getSubType()
        return subType;
    end

    function self:isEmpty()
        return item == nil;
    end

    return self;
end

return StorageSlot;
