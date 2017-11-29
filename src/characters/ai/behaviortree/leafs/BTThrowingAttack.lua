local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local ThrowingAttack = require( 'src.characters.actions.ThrowingAttack' );

local BTThrowingAttack = {};

function BTThrowingAttack.new()
    local self = BTLeaf.new():addInstance( 'BTThrowingAttack' );

    function self:traverse( ... )
        local blackboard, character = ...;

        local success = character:enqueueAction( ThrowingAttack( character, blackboard.target ))
        if success then
            -- Store weapon id for the rearm action.
            blackboard.weaponID = character:getWeapon():getID();
            Log.debug( 'Character attacks target', 'BTThrowingAttack' );
            return true;
        end

        Log.debug( 'Character can not attack target', 'BTThrowingAttack' );
        return false;
    end

    return self;
end

return BTThrowingAttack;
