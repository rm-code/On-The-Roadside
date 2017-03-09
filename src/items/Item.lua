local Object = require( 'src.Object' );

local Item = {};

function Item.new( template )
    local self = Object.new():addInstance( 'Item' );

    function self:getID()
        return template.id;
    end

    function self:getDescriptionID()
        return template.idDesc or 'default_item_description';
    end

    function self:getItemType()
        return template.itemType;
    end

    function self:getSubType()
        return template.subType;
    end

    function self:isSameType( itemType, subType )
        if template.itemType == itemType then
            if not subType or subType == template.subType then
                return true;
            end
        end
        return false;
    end

    function self:getWeight()
        return template.weight;
    end

    function self:getVolume()
        return template.volume;
    end

    function self:isEquippable()
        return template.equippable;
    end

    function self:isStackable()
        return template.stackable;
    end

    function self:isPermanent()
        return template.permanent;
    end

    function self:serialize()
        local t = {
            ['id'] = template.id,
            ['itemType'] = template.itemType
        };
        return t;
    end

    return self;
end

return Item;
