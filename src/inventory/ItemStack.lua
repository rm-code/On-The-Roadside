local Object = require( 'src.Object' );

local ItemStack = {};

function ItemStack.new( id )
    local self = Object.new():addInstance( 'ItemStack' );

    if not id or type( id ) ~= 'string' then error( 'Expected a parameter of type "string".' ) end;

    local items = {};

    function self:addItem( item )
        assert( item:getID() == id, 'ID doesn\'t fit the stack' );
        items[#items + 1] = item;
        return true;
    end

    function self:removeItem( item )
        for i = 1, #items do
            if items[i] == item then
                table.remove( items, i );
                return true;
            end
        end
        return false;
    end

    function self:getWeight()
        local weight = 0;
        for i = 1, #items do
            weight = weight + items[i]:getWeight();
        end
        return weight;
    end

    function self:getVolume()
        local volume = 0;
        for i = 1, #items do
            volume = volume + items[i]:getVolume();
        end
        return volume;
    end

    function self:split()
        if #items > 1 then
            local count = math.floor( #items * 0.5 );
            local newStack = ItemStack.new( id );
            for i = 1, count do
                newStack:addItem( items[i] );
                self:removeItem( items[i] );
            end
            return newStack;
        end
    end

    function self:serialize()
        local t = {
            ['ItemStack'] = true,
            ['id'] = id,
            ['items'] = {}
        };
        for i = 1, #items do
            t['items'][i] = items[i]:serialize();
        end
        return t;
    end

    function self:isSameType( itemType, subType )
        return items[#items]:isSameType( itemType, subType )
    end

    function self:getItem()
        return items[#items];
    end

    function self:getItems()
        return items;
    end

    function self:getItemType()
        return items[#items]:getItemType();
    end

    function self:getDescriptionID()
        return items[#items]:getDescriptionID();
    end

    function self:getID()
        return id;
    end

    function self:getItemCount()
        return #items;
    end

    function self:isEmpty()
        return #items == 0;
    end

    return self;
end

return ItemStack;
