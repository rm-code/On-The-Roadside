local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local MeleeAttack = require( 'src.characters.actions.MeleeAttack' );

local BTMeleeAttack = {};

function BTMeleeAttack.new()
    local self = BTLeaf.new():addInstance( 'BTMeleeAttack' );

    function self:traverse( ... )
        local blackboard, character, states, factions = ...;

        local success = character:enqueueAction( MeleeAttack.new( character, blackboard.target ));
        if success then
            Log.debug( 'Character attacks target', 'BTMeleeAttack' );
            return true;
        end

        Log.debug( 'Character can not attack target', 'BTMeleeAttack' );
        return false;
    end

    return self;
end

return BTMeleeAttack;
