local Object = require( 'src.Object' );
local EquipmentSlot = require( 'src.characters.inventory.EquipmentSlot' );

local Inventory = {};

function Inventory.new()
    local self = Object.new():addInstance( 'Inventory' );

    local primaryWeaponSlot = EquipmentSlot.new( 'Weapon' );

    function self:equipPrimaryWeapon( weapon )
        primaryWeaponSlot:setItem( weapon );
    end

    function self:getPrimaryWeapon()
        return primaryWeaponSlot:getItem();
    end

    return self;
end

return Inventory;
