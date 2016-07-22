local Object = require( 'src.Object' );

local Inventory = {};

function Inventory.new()
    local self = Object.new():addInstance( 'Inventory' );

    local items = {};

    function self:addItem( item )
        items[#items + 1] = item;
    end

    function self:removeItem( item )
        for i, citem in pairs( items ) do
            if item == citem then
                table.remove( items, i );
                print( 'Removed ' .. item:getName() .. ' at index ' .. i );
            end
        end
    end

    function self:isEmpty()
        return #items == 0;
    end

    function self:getItems()
        return items;
    end

    return self;
end

return Inventory;
