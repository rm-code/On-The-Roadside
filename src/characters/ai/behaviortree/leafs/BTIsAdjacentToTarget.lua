local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTIsAdjacentToTarget = {};

function BTIsAdjacentToTarget.new()
    local self = BTLeaf.new():addInstance( 'BTIsAdjacentToTarget' );

    function self:traverse( ... )
        local blackboard, character = ...;

        local result = character:getTile():isAdjacent( blackboard.target );
        Log.debug( result, 'BTIsAdjacentToTarget' );
        return result;
    end

    return self;
end

return BTIsAdjacentToTarget;
