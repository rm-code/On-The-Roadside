local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTCanReload = {};

function BTCanReload.new()
    local self = BTLeaf.new():addInstance( 'BTCanReload' );

    function self:traverse( ... )
        print( 'BTCanReload' );
        local _, character = ...;

        local weapon = character:getEquipment():getWeapon();
        local inventory = character:getEquipment():getBackpack():getInventory();
        for _, item in pairs( inventory:getItems() ) do
            if item:instanceOf( 'Magazine' ) and item:getCaliber() == weapon:getCaliber() then
                print( 'Character has ammo -> Can reload!' );
                return true;
            end
        end

        print( 'Character has no ammo -> Can\'t reload!' );

        return false;
    end

    return self;
end

return BTCanReload;
