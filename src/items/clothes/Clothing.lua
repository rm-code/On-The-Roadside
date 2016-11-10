local Item = require( 'src.items.Item' );

local Clothing = {};

function Clothing.new( template )
    local self = Item.new( template ):addInstance( 'Clothing' );

    local armorProtection = template.armor.protection;
    local armorCoverage = template.armor.coverage;

    function self:getArmorProtection()
        return armorProtection;
    end

    function self:getArmorCoverage()
        return armorCoverage;
    end

    return self;
end

return Clothing;
