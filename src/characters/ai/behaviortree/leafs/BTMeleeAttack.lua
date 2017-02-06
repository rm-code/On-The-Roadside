local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local MeleeAttack = require( 'src.characters.actions.MeleeAttack' );

local BTMeleeAttack = {};

function BTMeleeAttack.new()
    local self = BTLeaf.new():addInstance( 'BTMeleeAttack' );

    function self:traverse( ... )
        Log.info( 'BTMeleeAttack' );
        local blackboard, character, states = ...;

        character:enqueueAction( MeleeAttack.new( character, blackboard.target ));
        states:push( 'execution', character );

        return true;
    end

    return self;
end

return BTMeleeAttack;
