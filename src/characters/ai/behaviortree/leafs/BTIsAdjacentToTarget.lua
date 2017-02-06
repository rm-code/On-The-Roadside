local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTIsAdjacentToTarget = {};

function BTIsAdjacentToTarget.new()
    local self = BTLeaf.new():addInstance( 'BTIsAdjacentToTarget' );

    function self:traverse( ... )
        Log.info( 'BTIsAdjacentToTarget' );
        local blackboard, character = ...;

        if character:getTile():isAdjacent( blackboard.target ) then
            Log.info( 'Character is adjacent to target.' );
            return true;
        end

        Log.info( 'Character is not adjacent to target.' );

        return false;
    end

    return self;
end

return BTIsAdjacentToTarget;
