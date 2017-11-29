local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local RangedAttack = require( 'src.characters.actions.RangedAttack' )

local BTAttackTarget = {};

function BTAttackTarget.new()
    local self = BTLeaf.new():addInstance( 'BTAttackTarget' );

    function self:traverse( ... )
        local blackboard, character = ...;

        local success = character:enqueueAction( RangedAttack( character, blackboard.target ))
        if success then
            Log.debug( 'Character attacks target', 'BTAttackTarget' );
            return true;
        end

        Log.debug( 'Character can not attack target', 'BTAttackTarget' );
        return false;
    end

    return self;
end

return BTAttackTarget;
