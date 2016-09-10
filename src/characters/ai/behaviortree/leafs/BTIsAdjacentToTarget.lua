local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTIsAdjacentToTarget = {};

function BTIsAdjacentToTarget.new()
    local self = BTLeaf.new():addInstance( 'BTIsAdjacentToTarget' );

    function self:traverse( ... )
        print( 'BTIsAdjacentToTarget' );
        local blackboard, character = ...;

        if character:getTile():isAdjacent( blackboard.target ) then
            print( 'Character is adjacent to target.' );
            return true;
        end

        print( 'Character is not adjacent to target.' );

        return false;
    end

    return self;
end

return BTIsAdjacentToTarget;
