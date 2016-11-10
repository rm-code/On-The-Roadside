local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTCanAttack = {};

function BTCanAttack.new()
    local self = BTLeaf.new():addInstance( 'BTCanAttack' );

    function self:traverse( ... )
        print( 'BTCanAttack' );
        local _, character = ...;

        if character:getInventory():getWeapon():getMagazine():isEmpty() then
            return false;
        end

        return true;
    end

    return self;
end

return BTCanAttack;
