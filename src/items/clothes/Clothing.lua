local Item = require( 'src.items.Item' );

local Clothing = {};

function Clothing.new( id, itemType, armor )
    local self = Item.new( id, itemType ):addInstance( 'Clothing' );

    local armorProtection = armor.protection;
    local armorCoverage = armor.coverage;

    function self:getArmorProtection()
        return armorProtection;
    end

    function self:getArmorCoverage()
        return armorCoverage;
    end

    return self;
end

return Clothing;
