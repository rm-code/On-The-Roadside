local Object = require( 'src.Object' );
local StorageSlot = require( 'src.inventory.StorageSlot' );

local Storage = {};

function Storage.new( nslots )
    local self = Object.new():addInstance( 'Storage' );

    local slots = {};
    if type( nslots ) == 'number' then
        for _ = 1, nslots do
            slots[#slots + 1] = StorageSlot.new();
        end
    else
        for i, type in ipairs( nslots ) do
            slots[i] = StorageSlot.new( type[1], type[2] );
        end
    end

    function self:getSlots()
        return slots;
    end

    function self:addItem( item )
        for _, slot in ipairs( slots ) do
            if slot:isEmpty() and slot:canEquip( item ) then
                slot:addItem( item );
                break;
            end
        end
    end

    function self:isEmpty()
        for _, slot in ipairs( slots ) do
            if not slot:isEmpty() then
                return false;
            end
        end
        return true;
    end

    return self;
end

return Storage;
