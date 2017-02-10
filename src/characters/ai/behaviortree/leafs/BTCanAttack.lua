local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTCanAttack = {};

function BTCanAttack.new()
    local self = BTLeaf.new():addInstance( 'BTCanAttack' );

    function self:traverse( ... )
        local _, character = ...;

        local result = not character:getWeapon():getMagazine():isEmpty();
        Log.debug( result, 'BTCanAttack' );
        return result;
    end

    return self;
end

return BTCanAttack;
