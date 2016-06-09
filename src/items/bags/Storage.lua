local Object = require( 'src.Object' );
local StorageSlot = require( 'src.items.bags.StorageSlot' );

local Storage = {};

function Storage.new( space )
    local self = Object.new():addInstance( 'Storage' );

    local slots = {};
    for _ = 1, space do
        slots[#slots + 1] = StorageSlot.new();
    end

    function self:getSlots()
        return slots;
    end

    function self:addItem( item )
        for _, slot in ipairs( slots ) do
            if slot:isEmpty() then
                slot:setItem( item );
                break;
            end
        end
    end

    return self;
end

return Storage;
