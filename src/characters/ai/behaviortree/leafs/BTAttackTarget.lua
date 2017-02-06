local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local Attack = require( 'src.characters.actions.Attack' );

local BTAttackTarget = {};

function BTAttackTarget.new()
    local self = BTLeaf.new():addInstance( 'BTAttackTarget' );

    function self:traverse( ... )
        Log.info( 'BTAttackTarget' );
        local blackboard, character, states = ...;

        character:enqueueAction( Attack.new( character, blackboard.target ));
        states:push( 'execution', character );

        return true;
    end

    return self;
end

return BTAttackTarget;
