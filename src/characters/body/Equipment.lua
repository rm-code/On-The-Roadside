local Log = require( 'src.util.Log' );
local Observable = require( 'src.util.Observable' );
local ItemFactory = require( 'src.items.ItemFactory' );

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
                if not item:isPermanent() then
                    tile:getInventory():addItem( item );
                end
                slot:removeItem();
            end
        end
    end

    function self:removeItem( slot )
        local item = slot:getItem();
        -- TODO search through item table.
        if item:instanceOf( 'Container' ) then
            self:publish( 'CHANGE_VOLUME', -item:getCarryCapacity() );
        end

        slot:removeItem();
        return item;
    end

    function self:searchAndRemoveItem( item )
        for _, slot in pairs( slots ) do
            if item == slot:getItem() then
                return self:removeItem( slot );
            end
        end
    end

    function self:addItem( slot, item )
        if slot:getItemType() == item:getItemType() then
            if not slot:getSubType() or slot:getSubType() == item:getSubType() then
                -- Notify observers of a volume change.
                if item:instanceOf( 'Container' ) then
                    self:publish( 'CHANGE_VOLUME', item:getCarryCapacity() );
                end

                slot:addItem( item );
                return true;
            end
        end
        Log.warn( string.format( 'No applicable slot found for item %s', item:getID() ), 'Equipment' );
        return false;
    end

    function self:serialize()
        local t = {};
        for _, slot in pairs( slots ) do
            t[slot:getIndex()] = slot:serialize();
        end
        return t;
    end

    function self:load( savedEquipment )
        for index, slot in pairs( savedEquipment ) do
            if slot.item then
                slots[index]:addItem( ItemFactory.loadItem( slot.item ));
            end
        end
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
