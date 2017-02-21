local Log = require( 'src.util.Log' );
local Observable = require( 'src.util.Observable' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Equipment = {};

function Equipment.new()
    local self = Observable.new():addInstance( 'Equipment' );

    local slots = {};

    function self:addSlot( slot )
        local index = slot:getIndex();
        assert( not slots[index], 'ID already used! BodyParts have to be unique.' );
        slots[index] = slot;
    end

    function self:dropAllItems( tile )
        for _, slot in pairs( slots ) do
            if slot:containsItem() then
                local item = slot:getItem();
                tile:getInventory():addItem( item );
                slot:removeItem();
            end
        end
    end

    function self:removeItem( slot )
        local item = slot:getItem();

        if item:instanceOf( 'Bag' ) then
            self:publish( 'CHANGE_VOLUME', -item:getCarryCapacity() );
        end

        slot:removeItem();
        return item;
    end

    function self:addItem( slot, item )
        if slot:getItemType() == item:getItemType() then
            if not slot:getSubType() or slot:getSubType() == item:getSubType() then
                -- Notify observers of a volume change.
                if item:instanceOf( 'Bag' ) then
                    self:publish( 'CHANGE_VOLUME', item:getCarryCapacity() );
                end

                slot:addItem( item );
                return true;
            end
        end
        Log.warn( string.format( 'No applicable slot found for item %s', item:getID() ), 'Equipment' );
        return false;
    end

    ---
    -- Gets an item of the specified type without removing it from the inventory.
    -- @param type (string) The type of item to get.
    -- @return     (Item)   An item of the specified type.
    --
    function self:getItem( type )
        for _, slot in pairs( slots ) do
            if slot:getItemType() == type then
                return slot:getItem();
            end
        end
    end

    function self:getSlots()
        return slots;
    end

    return self;
end

return Equipment;
