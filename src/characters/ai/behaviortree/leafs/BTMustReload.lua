local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTMustReload = {};

function BTMustReload.new()
    local self = BTLeaf.new():addInstance( 'BTMustReload' );

    function self:traverse( ... )
        print( 'BTMustReload' );
        local _, character = ...;

        if character:getWeapon():getMagazine():isEmpty() then
            print( 'Magazine is empty -> We must reload!' );
            return true;
        end

        print( 'Magazine is not empty -> We must not reload!' );

        return false;
    end

    return self;
end

return BTMustReload;
