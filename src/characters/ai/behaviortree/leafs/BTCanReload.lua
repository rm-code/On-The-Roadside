local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTCanReload = {};

function BTCanReload.new()
    local self = BTLeaf.new():addInstance( 'BTCanReload' );

    function self:traverse( ... )
        Log.info( 'BTCanReload' );
        local _, character = ...;

        local weapon = character:getWeapon();
        local inventory = character:getBackpack():getInventory();
        for _, item in pairs( inventory:getItems() ) do
            if item:instanceOf( 'Magazine' ) and item:getCaliber() == weapon:getCaliber() then
                Log.info( 'Character has ammo -> Can reload!' );
                return true;
            end
        end

        Log.info( 'Character has no ammo -> Can\'t reload!' );

        return false;
    end

    return self;
end

return BTCanReload;
