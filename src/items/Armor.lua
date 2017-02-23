local Item = require( 'src.items.Item' );

local Armor = {};

function Armor.new( template )
    local self = Item.new( template ):addInstance( 'Armor' );

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

return Armor;
