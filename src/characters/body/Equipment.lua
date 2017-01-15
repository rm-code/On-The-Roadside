local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Equipment = {};

function Equipment.new()
    local self = Object.new():addInstance( 'Equipment' );

    local slots = {};

    function self:addSlot( slot )
        local index = slot:getIndex();
        assert( not slots[index], 'ID already used! BodyParts have to be unique.' );
        slots[index] = slot;
    end

    function self:dropAllItems( tile )
        for _, slot in pairs( slots ) do
            if slot:containsItem() then
                tile:getInventory():addItem( slot:getAndRemoveItem() );
            end
        end
    end

    function self:addItem( item )
        for _, slot in pairs( slots ) do
            if slot:getItemType() == item:getItemType() then
                slot:addItem( item );
                print( string.format( 'Added item %s to slots slot %d %s', item:getID(), slot:getIndex(), slot:getID() ));
                return true;
            end
        end
        print( string.format( 'No applicable slot found for item %s', item:getID() ));
        return false;
    end

    function self:removeItem( item )
        for _, slot in pairs( slots ) do
            if slot:getItemType() == item:getItemType() and slot:containsItem() then
                slot:removeItem();
                return true;
            end
        end
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
