local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local ThrowingAttack = require( 'src.characters.actions.ThrowingAttack' );
local Rearm = require( 'src.characters.actions.Rearm' );

local BTThrowingAttack = {};

function BTThrowingAttack.new()
    local self = BTLeaf.new():addInstance( 'BTThrowingAttack' );

    function self:traverse( ... )
        local blackboard, character, states, factions = ...;

        local success = character:enqueueAction( ThrowingAttack.new( character, blackboard.target ));
        if success then
            -- TODO move this to its own node
            local weapon = character:getBackpack():getInventory():getWeapon();
            if weapon then
                character:enqueueAction( Rearm.new( character, weapon:getID() ));
            end

            Log.debug( 'Character attacks target', 'BTThrowingAttack' );
            states:push( 'execution', factions, character );
            return true;
        end

        Log.debug( 'Character can not attack target', 'BTThrowingAttack' );
        return false;
    end

    return self;
end

return BTThrowingAttack;
