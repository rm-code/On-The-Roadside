local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTCanReload = {};

function BTCanReload.new()
    local self = BTLeaf.new():addInstance( 'BTCanReload' );

    function self:traverse( ... )
        local _, character = ...;

        local weapon = character:getWeapon();
        local inventory = character:getInventory();
        for _, item in pairs( inventory:getItems() ) do
            if item:instanceOf( 'Magazine' ) and item:getCaliber() == weapon:getCaliber() then
                Log.debug( 'Character can reload', 'BTCanReload' );
                return true;
            end
        end

        Log.debug( 'Character can not reload', 'BTCanReload' );
        return false;
    end

    return self;
end

return BTCanReload;
