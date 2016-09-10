local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local ThrowingAttack = require( 'src.characters.actions.ThrowingAttack' );

local BTGrenadeAttack = {};

function BTGrenadeAttack.new()
    local self = BTLeaf.new():addInstance( 'BTGrenadeAttack' );

    function self:traverse( ... )
        print( 'BTGrenadeAttack' );
        local blackboard, character, states = ...;

        character:enqueueAction( ThrowingAttack.new( character, blackboard.target ));
        states:push( 'execution', character );

        return true;
    end

    return self;
end

return BTGrenadeAttack;
