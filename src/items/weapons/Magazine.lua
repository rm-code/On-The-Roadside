local Item = require( 'src.items.Item' );
local AmmunitionEffects = require( 'src.items.weapons.AmmunitionEffects' );

local Magazine = {};

function Magazine.new( template )
    local self = Item.new( template ):addInstance( 'Magazine' );

    local capacity = 0;
    local rounds = 0;
    local effects = AmmunitionEffects.new( template.effects );

    function self:removeShell()
        rounds = rounds - 1;
    end

    function self:getRounds()
        return rounds;
    end

    function self:getCapacity()
        return capacity;
    end

    function self:getCaliber()
        return template.id;
    end

    function self:isFull()
        return rounds == capacity;
    end

    function self:isEmpty()
        return rounds == 0;
    end

    function self:setRounds( nrounds )
        rounds = nrounds;
    end

    function self:setCapacity( ncapacity )
        capacity = ncapacity;
    end

    function self:getEffects()
        return effects;
    end

    function self:serialize()
        local t = {
            ['id'] = template.id,
            ['itemType'] = template.itemType,
            ['rounds'] = rounds,
            ['capacity'] = capacity
        }
        return t;
    end

    return self;
end

return Magazine;
