local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );
local PathFinder = require( 'src.characters.pathfinding.PathFinder' );

local BTMoveToTarget = {};

function BTMoveToTarget.new()
    local self = BTLeaf.new():addInstance( 'BTMoveToTarget' );

    local path;

    local function generatePath( target, character )
        if target and target:isPassable() and not target:isOccupied() then
            path = PathFinder.generatePath( character, target, true );
        end
    end

    function self:traverse( ... )
        local blackboard, character = ...;

        local closest;
        local distance;

        -- Find the closest neighbour tile to move to.
        for _, neighbour in pairs( blackboard.target:getNeighbours() ) do
            if neighbour:isPassable() and not neighbour:isOccupied() then
                if not closest then
                    closest = neighbour;
                    local px, py = closest:getPosition();
                    local cx, cy = character:getTile():getPosition();
                    distance = math.sqrt(( px - cx ) * ( px - cx ) + ( py - cy ) * ( py - cy ));
                else
                    local px, py = neighbour:getPosition();
                    local cx, cy = character:getTile():getPosition();
                    local newDistance = math.sqrt(( px - cx ) * ( px - cx ) + ( py - cy ) * ( py - cy ));
                    if newDistance < distance then
                        closest = neighbour;
                        distance = newDistance;
                    end
                end
            end
        end

        if closest then
            generatePath( closest, character );
            if path then
                local success = path:generateActions( character );
                if success then
                    Log.debug( 'Character moves to target.', 'BTMoveToTarget' );
                    return true;
                end
            end
            Log.debug( 'No path found.', 'BTMoveToTarget' );
        end

        Log.debug( 'No target tile found', 'BTMoveToTarget' );
        return false;
    end

    return self;
end

return BTMoveToTarget;
