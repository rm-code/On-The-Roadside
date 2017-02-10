local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local Rearm = require( 'src.characters.actions.Rearm' );

local BTRearm = {};

function BTRearm.new()
    local self = BTLeaf.new():addInstance( 'BTRearm' );

    function self:traverse( ... )
        local blackboard, character, states, factions = ...;

        local success = character:enqueueAction( Rearm.new( character, blackboard.weaponID ));
        if success then
            Log.debug( 'Equipping throwing weapon ' .. blackboard.weaponID, 'BTRearm' );
            return true;
        end

        Log.debug( 'Equipping throwing weapon', 'BTRearm' );
        return false;
    end

    return self;
end

return BTRearm;
